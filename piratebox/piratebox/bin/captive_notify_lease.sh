#!/bin/sh

# Script to notify captive notification database about lease add and del.
# If captive_notify is disabled, this script exists only.
#   (to save cpu cycles).
#
# Arguments:
#    add | del | old | show  ; old is ignored
#    <mac>  ; ignored
#    <ip>   ; used
#
# GPL-3 (c)2017 , Matthias Strubel <matthias.strubel@aod-rpg.de>
#
op="${1:-op}"
ip="${3:-ip}"

. /opt/piratebox/conf/piratebox.conf

if [ "$FEATURE_CAPTIVE" = "no" ] ; then
    exit 0
fi

if [ "$op" = "refresh" ] ; then
    echo "Preparing Captive Portal Housekeeping file"
    test -e /tmp/captive.sqlite && rm /tmp/captive.sqlite
    touch /tmp/captive.sqlite ; chmod g+w /tmp/captive.sqlite
    chown root:$LIGHTTPD_GROUP /tmp/captive.sqlite
    exit 0
fi

echo "$op ; $ip"

if [ "$op" = "show" ] ; then
    wget -q -O - "http://127.0.0.1/captive/dnsmasq_cli.php?type=$op&ip=$ip"
else
    wget -q -O - "http://127.0.0.1/captive/dnsmasq_cli.php?type=$op&ip=$ip" > /dev/null
fi
