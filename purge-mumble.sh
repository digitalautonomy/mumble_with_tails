#!/bin/bash

ETC_ROOT=/etc
TORRC_ROOT=/etc/tor
HSDIR_ROOT=/var/lib/tor
PERSISTENT_DEVICE=/dev/mapper/TailsData_unlocked
PERSISTENT_ROOT=/home/amnesia/Persistent

# Starting the purge
echo "Stopping Mumble Server"
systemctl stop mumble-server.service

echo "Purging mumble"
apt purge mumble mumble-server -y
apt autoremove -y

echo "Restoring torrc"
cp -pv ${TORRC_ROOT}/torrc.orig ${TORRC_ROOT}/torrc

echo "Removing Mumble hosting file"
rm -r ${HSDIR_ROOT}/mumble-server

echo "Restarting Tor service"
systemctl restart tor

# Purge data for persistent mode.
if [ -e ${PERSISTENT_DEVICE} ]
then
    echo "Purging persistent data for Mumble"
    rm -f ${ETC_ROOT}/mumble-server.ini.orig
    rm -f ${PERSISTENT_ROOT}/mumble-server.ini
    rm -rf ${PERSISTENT_ROOT}/mumble-server
fi