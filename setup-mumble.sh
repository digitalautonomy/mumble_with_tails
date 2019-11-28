#!/bin/bash

TORRC_ROOT=/etc/tor
ETC_ROOT=/etc
HSDIR_ROOT=/var/lib/tor
PERSISTENT_DEVICE=/dev/mapper/TailsData_unlocked
PERSISTENT_ROOT=/home/amnesia/Persistent

# Hidden Service port
HS_PORT=64738

MUMBLE_SERVER_STATUS=-1
TOR_STATUS=-1

ONION_URL='-'

## Validating Tor service status
TOR_STATUS=$(systemctl is-active tor)
echo "Tor service status ${TOR_STATUS}"

if [ "${TOR_STATUS}" == "inactive" ];
then
    echo "Starting Tor service"
    systemctl start tor
    sleep 5
fi

## Install Mumble Client and Server
apt-get update
apt-get install mumble-server mumble -y

## Configure Hidden Service script for Mumble
echo "Backing up original torrc configuration"
cp -pv ${TORRC_ROOT}/torrc ${TORRC_ROOT}/torrc.orig

echo "Configure Hidden Service for Mumble in torrc"
sed -e "/#HiddenServicePort 22 127.0.0.1:22/a \
\\\\n\
# Mumble hidden service configuration.\n\
HiddenServiceDir ${HSDIR_ROOT}/mumble-server/\n\
HiddenServicePort ${HS_PORT} 127.0.0.1:${HS_PORT}" \
    < ${TORRC_ROOT}/torrc.orig \
    > ${TORRC_ROOT}/torrc

## Configure Mumble Server script to listen only on localhost
echo "Backing up original Mumble Server configuration"
cp -pv ${ETC_ROOT}/mumble-server.ini ${ETC_ROOT}/mumble-server.ini.orig

echo "Configure Mumble Server to bind to localhost"
sed -e "s/#host=/host=localhost/" \
    < ${ETC_ROOT}/mumble-server.ini.orig \
    > ${ETC_ROOT}/mumble-server.ini

## Validating Mumble server service status
MUMBLE_SERVER_STATUS=$(systemctl is-active mumble-server.service)
echo "Mumble Server status ${MUMBLE_SERVER_STATUS}"

if [ "${MUMBLE_SERVER_STATUS}" == "active" ];
then
    echo "Restarting Mumble Server"
    systemctl restart mumble-server.service
fi

## Validating Tor service status, make sure it is running.
TOR_STATUS=$(systemctl is-active tor)
echo "Tor service status ${TOR_STATUS}"

if [ "${TOR_STATUS}" == "active" ];
then
    echo "Restarting Tor service"
    systemctl restart tor

    for i in {1..6}
    do
        if [ -f ${HSDIR_ROOT}/mumble-server/hostname ];
        then
            echo "Mumble Hidden Service hosted successfully!!!"
            break
        fi

        echo "Mumble Hidden Service not yet running, please wait... attempt ${i}/6"
        sleep 5
    done

    if [ -f ${HSDIR_ROOT}/mumble-server/hostname ];
    then
        ONION_URL=$(cat ${HSDIR_ROOT}/mumble-server/hostname)
        echo ${ONION_URL} | xclip -selection c
        echo "******************************************************************"
        echo "Onion HiddenService URL: ${ONION_URL} was copied to clipboard"
        echo "******************************************************************"
        echo
        echo "************************************************"
        echo " Please run Mumble from a non-root shell"
        echo "************************************************"
    else
        echo "************************************************"
        echo "Mumble Hidden Service hosting failed!!!"
        echo "Please check the system and try again..."
        echo "************************************************"
    fi
fi

## Save data for persistent mode.
if [ -e ${PERSISTENT_DEVICE} ]
then
    echo "Saving Mumble settings"
    cp -avr ${HSDIR_ROOT}/mumble-server ${PERSISTENT_ROOT}
    cp -pv ${ETC_ROOT}/mumble-server.ini ${PERSISTENT_ROOT}
    cp -pv ${TORRC_ROOT}/torrc ${PERSISTENT_ROOT}
fi