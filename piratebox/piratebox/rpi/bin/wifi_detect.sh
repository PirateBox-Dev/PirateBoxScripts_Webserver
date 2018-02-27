#!/bin/sh

# Install the proper hostapd package and adjust the hostapd configuration
# accordingly.

## Default
WIFI_DEVICE="wlan0"

WIFI_CONFIG_PATH="/boot/wifi_card.conf"

PACKAGE_PATH="/prebuild/hostapd"
CONFIG_PATH="/opt/piratebox/conf/hostapd.conf"
PIRATEBOX_CONFIG_PATH="/opt/piratebox/conf/piratebox.conf"

## Only use if it is set
if test -e "${WIFI_CONFIG_PATH}" ; then
    echo "Found wifi card config"
    WIFI_DEVICE=$( head -n 1 "${WIFI_CONFIG_PATH}" | tr -d '\n'  )
fi

hostap_interface=$( grep -e '^interface' "${CONFIG_PATH}" | sed -e 's|interface=||' )
piratebox_interface=$( grep -e '^INTERFACE' "${PIRATEBOX_CONFIG_PATH}" | \
                sed -e 's|INTERFACE=||' -e 's|"||g' )
dnsmasq_interface=$( grep -e '^DNSMASQ_INTERFACE' "${PIRATEBOX_CONFIG_PATH}" | \
                sed -e 's|DNSMASQ_INTERFACE=||' -e 's|"||g' )

sed -i -e "s|interface=$hostap_interface|interface=$WIFI_DEVICE|" "${CONFIG_PATH}"

#Only change piratebox interface if it is a wifi interface
if echo "$piratebox_interface" | grep -q "wlan" ; then
    sed -i -e "s|INTERFACE=\"$piratebox_interface\"|INTERFACE=\"$WIFI_DEVICE\"|" \
         "${PIRATEBOX_CONFIG_PATH}"
fi
if echo "$dnsmasq_interface" | grep -q "wlan" ; then
    sed -i -e "s|DNSMASQ_INTERFACE=\"$dnsmasq_interface\"|DNSMASQ_INTERFACE=\"$WIFI_DEVICE\"|" \
           "${PIRATEBOX_CONFIG_PATH}"
fi



## Get pyhX device node
CARD_ID=$( cat /sys/class/net/"${WIFI_DEVICE}"/phy80211/index )


# Check if we have an nl80211 enabled device with AP mode, then we are done
if iw phy phy"${CARD_ID}" info | grep -q "* AP$"; then
  echo "Found nl80211 device capable of AP mode..."
  pacman --noconfirm -U --needed "${PACKAGE_PATH}/hostapd-2"* > /dev/null
  sed -i 's/^#driver=nl80211/driver=nl80211/' "${CONFIG_PATH}"
  exit 0
fi

#Get driver name
DRIVER_NAME=$( ls -1 /sys/class/net/"${WIFI_DEVICE}"/device/driver/module/drivers/ )

# Check for r8188eu enabled device
if echo "$DRIVER_NAME"  | grep -q  "r8188eu"; then
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
  /opt/piratebox/rpi/bin/run_client.sh
  exit 1
  # Exit =! 0 will result in not starting piratebox service
fi

exit 1
