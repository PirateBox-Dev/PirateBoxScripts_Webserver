#!/bin/sh

# Install the proper hostapd package and adjust the hostapd configuration
# accordingly.

PACKAGE_PATH="/prebuild/hostapd"
CONFIG_PATH="/opt/piratebox/conf/hostapd.conf"

# Check if we have an nl80211 enabled device with AP mode, then we are done
if iw list | grep > /dev/null "* AP$"; then
  echo "Found nl80211 device capable of AP mode..."
  yes | pacman -U --needed "${PACKAGE_PATH}/hostapd-2"* > /dev/null
  sed -i 's/^#driver=nl80211/driver=nl80211/' "${CONFIG_PATH}"
  exit 0
fi

# Check for r8188eu enabled device
if dmesg | grep > /dev/null "r8188eu:"; then
  echo "Found r8188eu enabled device..."
  yes | pacman -U --needed "${PACKAGE_PATH}/hostapd-8188eu-"* > /dev/null
  sed -i 's/^driver=nl80211/#driver=nl80211/' "${CONFIG_PATH}"
  exit 0
fi

# Check for rtl8192cu enabled device
if dmesg | grep > /dev/null "rtl8192cu"; then
  echo "Found rtl8192cu enabled device..."
  yes | pacman -U --needed "${PACKAGE_PATH}/hostapd-8192cu-"* > /dev/null
  sed -i 's/^driver=nl80211/#driver=nl80211/' "${CONFIG_PATH}"
  exit 0
fi

echo "Could not find an AP enabled WiFi card..."

# Try to connect to Wifi if wpa_supplicant.conf is available.
if [ -f /boot/wpa_supplicant.conf ]; then
  echo "Found wpa_supplicant conf, trying to connect..."
  wpa_supplicant -iwlan0 -c /boot/wpa_supplicant.conf -B -D wext
  dhcpcd wlan0
fi

exit 1
