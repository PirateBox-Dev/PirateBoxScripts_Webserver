PIRATEBOX_HOSTS_MESH=/opt/piratebox/conf/hosts_mesh
AVAHI_CACHE_FILE=/tmp/avahi.browse
AVAHI_GEN_OUTPUT="${AVAHI_CACHE_FILE}".hosts

DNSMASQ_PID=/var/run/piratebox_dnsmasq.pid

SLEEPTIME=$((60 * 5 ))  # Sleep for 5 Minutes before doing a refresh

PROTOCOLL="_http._tcp"

while true; do

	## Browse Avahi discover results and format them into a hosts file
	avahi-browse -p -r -t -f $PROTOCOLL  | grep -e "=" > $AVAHI_CACHE_FILE
	grep \= $AVAHI_CACHE_FILE | \
		sed -e 's|\.local||g' \
		   -e 's|_|\.|g' | \
		awk 'BEGIN { FS=";" } { print $8 " " $7; }' > $AVAHI_GEN_OUTPUT


	echo "# Updated " `date` >> $AVAHI_GEN_OUTPUT
	cp $AVAHI_GEN_OUTPUT   $PIRATEBOX_HOSTS_MESH

	# Send SIGHUP to dnsmasq for refreshing its cache
	kill -1 `cat $DNSMASQ_PID`
	sleep $SLEEPTIME
done
