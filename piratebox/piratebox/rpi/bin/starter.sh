#!/bin/sh
# Try to setup WiFi and if it succeeds, start the PirateBox

## Default 
WIFI_DEVICE="wlan0"

WIFI_CONFIG_PATH="/boot/wifi_card.conf"

if test -e "${WIFI_CONFIG_PATH}" ; then
    echo "Found wifi card config"
    WIFI_DEVICE=$( head -n 1 "${WIFI_CONFIG_PATH}" | tr -d '\n'  )
fi


if [ "${INTERFACE}" = "${WIFI_DEVICE}" ] ; then
    /bin/sh -c /opt/piratebox/rpi/bin/wifi_detect.sh && /usr/bin/systemctl start piratebox
fi
exit 0
