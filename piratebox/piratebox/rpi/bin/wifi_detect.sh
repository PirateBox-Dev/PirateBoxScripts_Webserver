#!/bin/sh

# Install the proper hostapd package and adjust the hostapd configuration
# accordingly.

## Default 
WIFI_DEVICE="wlan0"  

WIFI_CONFIG_PATH="/boot/wifi_card.conf"

PACKAGE_PATH="/prebuild/hostapd"
CONFIG_PATH="/opt/piratebox/conf/hostapd.conf"

## Only use if it is set
if test -e "${WIFI_CONFIG_PATH}" ; then
    echo "Found wifi card config"
    WIFI_DEVICE=$( head -n 1 "${WIFI_CONFIG_PATH}" | tr -d '\n'  )
fi

hostap_interface=$( grep -e '^interface' "${CONFIG_PATH}" | sed -e 's|interface=||' )

if [ "${hostap_interface}" = "${WIFI_DEVICE}" ] ; then 
    echo "No change in hostapd.conf for wifi device needed"
else
    sed -i -e "s|$hostap_interface|$WIFI_DEVICE|" "${CONFIG_PATH}"
fi

## Get pyhX device node
CARD_ID=$( cat /sys/class/net/"${WIFI_DEVICE}"/phy80211/index )


# Check if we have an nl80211 enabled device with AP mode, then we are done
if iw phy phy"${CARD_ID}" | grep -q "* AP$"; then
  echo "Found nl80211 device capable of AP mode..."
  pacman --noconfirm -U --needed "${PACKAGE_PATH}/hostapd-2"* > /dev/null
  sed -i 's/^#driver=nl80211/driver=nl80211/' "${CONFIG_PATH}"
  exit 0
fi

#Get driver name
DRIVER_NAME=$( ls -1 /sys/class/net/"${WIFI_DEVICE}"/device/driver/module/drivers/ )

# Check for r8188eu enabled device
if echo "$DRIVER_NAME"  | grep -q  "r8188eu:"; then
  echo "Found r8188eu enabled device..."
  pacman --noconfirm  -U --needed "${PACKAGE_PATH}/hostapd-8188eu-"* > /dev/null
  sed -i 's/^driver=nl80211/#driver=nl80211/' "${CONFIG_PATH}"
  exit 0
fi


# Check for rtl8192cu enabled device
if echo "$DRIVER_NAME"  | grep -q "rtl8192cu"; then
  echo "Found rtl8192cu enabled device..."
  pacman --noconfirm -U --needed "${PACKAGE_PATH}/hostapd-8192cu-"* > /dev/null
  sed -i 's/^driver=nl80211/#driver=nl80211/' "${CONFIG_PATH}"
  exit 0
fi

echo "Could not find an AP enabled WiFi card..."

# Try to connect to Wifi if wpa_supplicant.conf is available.
if [ -f /boot/wpa_supplicant.conf ]; then
  echo "Found wpa_supplicant conf, trying to connect..."
  wpa_supplicant -i"${WIFI_DEVICE}" -c /boot/wpa_supplicant.conf -B -D wext
  dhcpcd "${WIFI_DEVICE}"
fi

exit 1
