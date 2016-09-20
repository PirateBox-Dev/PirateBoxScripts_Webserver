#!/bin/sh

## Library for some kind of avahi-node name resolution
##  over piratebox mesh network
NODE_IP=""

## This function takes the normal
#    gjgtjtjt.piratebox.lan	
#  hostname converts it to:
#   gjgtjtjt_piratebox_lan.local 
#  makes an avahi resolution and gives back the IP in NODE_IP 
#   uf it was found
resolve_node_hostname() {
   local in_nodename=$1

   local AVAHI_HOST=$( echo $in_nodename | sed 's|\.|_|g' )
   local bonjour_hostname="$AVAHI_HOST"".local"
   local output=$( avahi-resolve-host-name -6 $bonjour_hostname )

   if [ ! -z "$output" ] ; then
	echo "Found host: $output"
	#Sorry for that worse splitup of name and IP
	NODE_IP=$( echo $output | sed "s|$bonjour_hostname||" )
	return 0 
   else
	return 1
   fi


}
