#!/bin/sh
#  by Matthias Strubel ,  2012
#   
#   Sends a SIGHUB to dnsmasq to reread its hosts files
#     Needed for mesh feature. Will enable easy dns-service for this.

PIDFILE_DNSMASQ=/var/run/piratebox_dnsmasq.pid

. /opt/piratebox/conf/piratebox.conf
. "${MODULE_CONFIG}/dnsmasq.conf"

DNSMASQ_PID="${DNSMASQ_PIDFILE}"


kill -1 `cat $PIDFILE_DNSMASQ`
kill -1 `cat $DNSMASQ_PID`
