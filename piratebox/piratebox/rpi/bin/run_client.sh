#!/bin/bash

# Runs with wpa_supplicant & wifi device from boot folder.

## Default
WIFI_DEVICE="wlan0"

WIFI_CONFIG_PATH="/boot/wifi_card.conf"
WPA_SUPPLICANT="/boot/wpa_supplicant.conf"

# Try to get wifi device
if test -e "${WIFI_CONFIG_PATH}" ; then
    echo "Found wifi card config"
    WIFI_DEVICE=$( head -n 1 "${WIFI_CONFIG_PATH}" | tr -d '\n'  )
fi

# Try to connect to Wifi if wpa_supplicant.conf is available.
if [ -f "${WPA_SUPPLICANT}" ]; then
    echo "Found wpa_supplicant conf, trying to connect..."
    wpa_supplicant -i"${WIFI_DEVICE}" -c "${WPA_SUPPLICANT}"  -B -D wext
    dhcpcd "${WIFI_DEVICE}"
    exit 0
else
    echo "Wifi configuration not found"
    exit 1
fi
exit 1
