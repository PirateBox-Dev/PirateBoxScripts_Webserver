#!/bin/sh

# Script to notify captive notification database about lease add and del.
# If captive_notify is disabled, this script exists only.
#   (to save cpu cycles).
#
# Arguments:
#    add | del | old   ; old is ignored
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


echo "$op ; $ip"

php "$PIRATEBOX_FOLDER"/bin/captive_cli.php "$op" "$ip" "$PIRATEBOX_FOLDER/"
