
. /opt/piratebox/conf/piratebox.conf

. "${MODULE_CONFIG}/config_generation.conf"
. "${MODULE_CONFIG}/dnsmasq.conf"

PIRATEBOX_HOSTS_MESH="${HOSTS_MESH}"
DNSMASQ_PID="${DNSMASQ_PIDFILE}"

SLEEPTIME=$((60 * 5 ))  # Sleep for 5 Minutes before doing a refresh


while true; do

	## Browse Avahi discover results and format them into a hosts file
	avahi-browse -f rtp_http._tcp | grep "=" > /tmp/avahi.browse
	grep \= /tmp/avahi-browse | \
		sed -e 's|\.local||g' \
		   -e 's|_|\.|g' | \
		awk 'BEGIN { FS=";" } { print $8 " " $7; }' > /tmp/avahi.browse.hosts


	echo "# Updated " `date` >> /tmp/avahi.browse.hosts
	cp /tmp/avahi.browse.hosts $PIRATEBOX_HOSTS_MESH

	# Send SIGHUP to dnsmasq for refreshing its cache
	kill -1 `cat $DNSMASQ_PID`
	sleep $SLEEPTIME
done
