#!/bin/sh

#  Matthias Strubel    (c) 2013-2014
#    licenced with GPL-3
#
# Generate severall configuration files out of piratebox.conf
#     conf/hosts_generated
#     conf/dnsmasq_generated.conf
#     conf/radvd_generated.conf
#     conf/lighttpd/env
#     conf/hosts_mesh
#
# There are files for default configuration or adding custom stuff:
#     conf/hosts
#     conf/dnsmasq_default.conf
#
#  it is using the following VARS out of piratebox.conf:
#    NET               = The network of your box  i.e. 192.168.1
#    IP_SHORT          = The ip of the piratebox  i.e. 1    results 192.168.1.1
#    START_LEASE       =   Range of dhcp leases  start  10
#    END_LEASE         =                         end    250
#    LEASE_DURATION    =    lease time           30min
#    HOSTNAME          =  piratebox.lan   - o'rly?  Maybe generate some additional stuff here
#  -
#    GLOBAL_CHAT       = Enable Broadcasts
#    GLOBAL_DEST       = Broadcast IP destinations
#    PYTHONPATH        = Path of PirateBox python libs
#    GEN_CHATFILE      = generated html chatfile
#    PIRATEBOX         = PirateBox Folder
#    CHATFILE          = data store for Shoutbox-content
#    
#    NODE_CONFIG       = Config file for Mesh-Node parameters
#  -
#  ipv6.conf (loaded within piratebox.conf)
#    IPV6_ENABLE	= enables IPv6 config
#    IPV6_ADVERT	= which service for advertising IPv6 Prefix
#    IPV6_MASK		= Netmask
#    IPV6_PREFIX	= Which prefix should be announced.
#  -
#  node.conf
#    NODE_CONFIG_ACTIVE = if yes, configure special ipv6-node-hostname
#    NODE_IPV6_IP	= Device specific IP
#    NODE_NAME & NODE_GEN = Settings for setting up Hostname
#
#  Matthias Strubel    -- 08.06.2012
#    licenced with GPL-3

CONFIG_PATH="conf"
DNSMASQ_CONFIG=""
HOSTS_CONFIG=""
DEFAULT_HOSTS=""
LEASE_FILE=""
RADVD_CONFIG=""
LIGHTTPD_ENV_CONFIG=""
AVAHI_SRC=""
AVAHI_CONFIG=""

set_pathnames() {
  CONFIG_PATH=$1/conf


  RADVD_CONFIG=$CONFIG_PATH/radvd_generated.conf
  LEASE_FILE=$LEASE_FILE_LOCATION
  LIGHTTPD_ENV_CONFIG=$CONFIG_PATH/lighttpd/conf.d/env.conf
  AVAHI_CONFIG=$CONFIG_PATH/avahi/avahi-daemon.conf
  AVAHI_SRC=$CONFIG_PATH/avahi/avahi-daemon.conf.schema

}

generate_hosts() {
   set_hostname=$1
   set_ipv4=$2
   set_ipv6=$3
   echo "Generating hosts file .... "
   cat  $DEFAULT_HOSTS                 >  $HOSTS_CONFIG
   echo "$set_ipv4     $set_hostname " >> $HOSTS_CONFIG
   echo "$set_ipv6     $set_hostname " >> $HOSTS_CONFIG
   
   touch "$HOSTS_MESH"
}


#------------ lighttpd env config - Start ---------------------

generate_lighttpd_env() {
        local GLOBAL_CHAT=$1
        local GLOBAL_DEST="$2"
	local PYTHONPATH=$3
	local SHOUTBOX_GEN_HTMLFILE=$4
	local PIRATEBOX=$5
	local SHOUTBOX_CHATFILE=$6
	local SHOUTBOX_CLIENT_TIMESTAMP=$7
	local IN_UPLOAD_PATH=$8

        echo "Generating Environment-config for lighttpd ....."

        LIGHTTPD_ENV_BR_LINE=""
	if [ "$GLOBAL_CHAT" = "yes" ] ; then
	     LIGHTTPD_ENV_BR_LINE="   \"SHOUTBOX_BROADCAST_DESTINATIONS\" => \"$GLOBAL_DEST\" , "
	fi

	LIGHTTPD_ENV="setenv.add-environment = ( 
	   \"PYTHONPATH\"             => \"$PYTHONPATH:$PIRATEBOX/python_lib\", 
	   \"SHOUTBOX_GEN_HTMLFILE\"  => \"$SHOUTBOX_GEN_HTMLFILE\" , 
	   \"SHOUTBOX_CHATFILE\"      => \"$SHOUTBOX_CHATFILE\" , 
	   \"SHOUTBOX_CLIENT_TIMESTAMP\" => \"$SHOUTBOX_CLIENT_TIMESTAMP\" , 
	   \"UPLOAD_PATH\" => \"$IN_UPLOAD_PATH\" , 
	   $LIGHTTPD_ENV_BR_LINE 

        )"

       echo $LIGHTTPD_ENV > $LIGHTTPD_ENV_CONFIG
}

#------------ lighttpd env config - End   ---------------------



if [ -z  $1 ] ; then
  echo "Usage is 
      generate_config_files.sh /opt/piratebox/conf/piratebox.conf
   "
   exit 255
fi

if [ !  -f $1 ] ; then
  echo "Config-File $1 not found..."
  exit 255
fi

. $1

. $NODE_CONFIG
. $PIRATEBOX_FOLDER/lib/node_name_generation.sh

IPV6="#"

set_pathnames  $PIRATEBOX_FOLDER

ipv6_call=''
if [ "$IPV6_ENABLE" = "yes" ] ; then
   ipv6_call=$IPV6_PREFIX
   IPV6=$IPV6_IP
fi
generate_hosts $HOST  $IP  $IPV6

generate_lighttpd_env $GLOBAL_CHAT "$GLOBAL_DEST" $PIRATEBOX_PYTHONPATH $GEN_CHATFILE $PIRATEBOX_FOLDER  $CHATFILE $SHOUTBOX_CLIENT_TIMESTAMP $UPLOADFOLDER

COMPLETE_HOST=$HOST

if [ "$NODE_CONFIG_ACTIVE" = "yes" ] ; then
     echo -n "Appending local node-name hosts entry "
     if generate_node_name "$HOST" "$NODE_NAME" "$NODE_GEN" ; then
	echo $NODE_GEN_OUTPUT
	echo "$NODE_IPV6_IP   $NODE_GEN_OUTPUT  " >> $HOSTS_CONFIG
	COMPLETE_HOST=$NODE_GEN_OUTPUT
     else 
	 echo "Error: No valid node-name-config found, skipping"
     fi
fi

#We want a long hostname and not only the hostname itself...
### PirateBox Scripts generates its own config in  /opt/piratebox/conf/avahi
###   but, the daemon works per default only on /etc/avahi
### If you want to enable avahi, then you have to link /etc/avahi to /opt/piratebox/conf/avahi
### On OpenWRT this should happen, if avahi is available before installing the piratebox
###  automtically. 
AVAHI_HOST=$( echo $COMPLETE_HOST | sed 's|\.|_|g' )
sed "s|#####MASKED_HOSTNAME#####|$AVAHI_HOST|" $AVAHI_SRC > $AVAHI_CONFIG
