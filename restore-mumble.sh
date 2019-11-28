#!/bin/bash

TORRC_ROOT=/etc/tor
ETC_ROOT=/etc
HSDIR_ROOT=/var/lib/tor
PERSISTENT_ROOT=/home/amnesia/Persistent
ONION_URL='-'

# Move folder and files needes from Persistent location to respective
# OS locations for order to host Mumble hidden service.
cp -avr ${PERSISTENT_ROOT} ${HSDIR_ROOT}
cp -pv ${PERSISTENT_ROOT}/mumble-server.ini ${ETC_ROOT}
cp -pv ${PERSISTENT_ROOT}/torrc ${TORRC_ROOT}

## Restart Tor service to initialize Mumble hidden service
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

## Get the Mumble Hidden Service URL and display it to the user
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
