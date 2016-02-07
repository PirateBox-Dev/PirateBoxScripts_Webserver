#!/bin/sh
# Try to setup WiFi and if it succeeds, start the PirateBox
/bin/sh -c /opt/piratebox/rpi/bin/wifi_detect.sh && /usr/bin/systemctl start piratebox
