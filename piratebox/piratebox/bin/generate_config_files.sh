#!/bin/sh

# Generate severall configuration files out of piratebox.conf
#     conf/hosts_generated
#     conf/dnsmasq_generated.conf
#     conf/radvd_generated.conf
#     conf/lighttpd/env
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

set_pathnames() {
  CONFIG_PATH=$1/conf
  DNSMASQ_CONFIG=$CONFIG_PATH/dnsmasq_generated.conf
  HOSTS_CONFIG=$CONFIG_PATH/hosts_generated
  HOSTS_MESH=$CONFIG_PATH/hosts_mesh
  DEFAULT_HOSTS=$CONFIG_PATH/hosts
  DEFAULT_DNSMASQ=$CONFIG_PATH/dnsmasq_default.conf
  RADVD_CONFIG=$CONFIG_PATH/radvd_generated.conf
  LEASE_FILE=$LEASE_FILE_LOCATION
  LIGHTTPD_ENV_CONFIG=$CONFIG_PATH/lighttpd/env
}

generate_hosts() {
   set_hostname=$1
   set_ipv4=$2
   set_ipv6=$3
   echo "Generating hosts file .... "
   cat  $DEFAULT_HOSTS                 >  $HOSTS_CONFIG
   echo "$set_ipv4     $set_hostname " >> $HOSTS_CONFIG
   echo "$set_ipv6     $set_hostname " >> $HOSTS_CONFIG
}

generate_dnsmasq() {
   net=$1
   lease_start=$3
   lease_end=$4
   lease_time=$5
   ip_pb=$2
   dnsmasq_interface=$6
   echo "Generating dnsmasq.conf ....."
   cat $DEFAULT_DNSMASQ                > $DNSMASQ_CONFIG

   #Add interface line if filled
   [ -n $dnsmasq_interface ] &&   echo "interface=$dnsmasq_interface" >> $DNSMASQ_CONFIG

   lease_line="$net.$lease_start,$net.$lease_end,$lease_time"
   echo  "dhcp-range=$lease_line"      >> $DNSMASQ_CONFIG
   #redirect every dns
   dns_redirect="/#/$net.$ip_pb"
   echo "address=$dns_redirect"        >> $DNSMASQ_CONFIG
   echo "dhcp-leasefile=$LEASE_FILE"   >> $DNSMASQ_CONFIG

   echo "addn-hosts=$HOSTS_CONFIG"     >>$DNSMASQ_CONFIG

   #Mesh hosts
   echo "addn-hosts=$HOSTS_MESH" 	>> $DNSMASQ_CONFIG

   if [ "$IPV6_ENABLE" = "yes" ] && [ "$IPV6_ADVERT" = "dnsmasq" ] ; then
     echo "Do additional v6 stuff in dnsmasq.conf"
     echo "#----- V6 Stuff"                     >> $DNSMASQ_CONFIG
     echo "dchp-range=$ipv6_call::, ra-stateless" >> $DNSMASQ_CONFIG
   fi

}

generate_radvd(){
  prefix=$1
  mask=$2
  interface=$3

  echo "#---- generated file ---"               > $RADVD_CONFIG  
  echo "
    interface $interface {
       AdvSendAdvert on;
       MinRtrAdvInterval 3;
       MaxRtrAdvInterval 10;
       prefix $prefix::/$mask {
           AdvOnLink on; 
	   AdvAutonomous on; 
	   AdvRouterAddr on; 
       };
    };
       "                                        >>  $RADVD_CONFIG

}

#------------ lighttpd env config - Start ---------------------

generate_lighttpd_env() {
        local GLOBAL_CHAT=$1
        local GLOBAL_DEST="$2"
	local PYTHONPATH=$3
	local SHOUTBOX_GEN_HTMLFILE=$4
	local PIRATEBOX=$5
	local SHOUTBOX_CHATFILE=$6

        echo "Generating Environment-config for ligttpd ....."

        LIGHTTPD_ENV_BR_LINE=""
	if [ "$GLOBAL_CHAT" = "yes" ] ; then
	     LIGHTTPD_ENV_BR_LINE="   \"SHOUTBOX_BROADCAST_DESTINATIONS\" => \"$GLOBAL_DEST\" , "
	fi

	LIGHTTPD_ENV="setenv.add-environment = ( 
	   \"PYTHONPATH\"             => \"$PYTHONPATH:$PIRATEBOX/python_lib\", 
	   \"SHOUTBOX_GEN_HTMLFILE\"  => \"$SHOUTBOX_GEN_HTMLFILE\" , 
	   \"SHOUTBOX_CHATFILE\"      => \"$SHOUTBOX_CHATFILE\" , 
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

IPV6="#"

set_pathnames  $PIRATEBOX_FOLDER

ipv6_call=''
if [ "$IPV6_ENABLE" = "yes" ] ; then
   ipv6_call=$IPV6_PREFIX
   IPV6=$IPV6_PREFIX:$IPV6_IP
   [[ "$IPV6_ADVERT" = "radvd" ]] && generate_radvd $IPV6_PREFIX  $IPV6_MASK $DNSMASQ_INTERFACE
fi
generate_hosts $HOST  $IP  $IPV6
generate_dnsmasq  $NET $IP_SHORT  $START_LEASE  $END_LEASE $LEASE_DURATION $DNSMASQ_INTERFACE
generate_lighttpd_env $GLOBAL_CHAT "$GLOBAL_DEST" $PIRATEBOX_PYTHONPATH $GEN_CHATFILE $PIRATEBOX_FOLDER  $CHATFILE



