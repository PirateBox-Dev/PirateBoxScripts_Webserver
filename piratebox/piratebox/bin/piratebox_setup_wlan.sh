#!/bin/bash

# Author: Matthias Strubel   (c) 2011-2014 GPL-3
#  Script for setting up the wlan interface
#  Parameter 1 i used for the config file providing the parameters

#   IP-Adress  IPv4 + IPv6
#   Netmask
#   Interface

probe() {
  if [ "$PROBE_INTERFACE" = "yes" ] ; then
     echo -n "Probing interface $INTERFACE"
     ifconfig  "$INTERFACE"  >> /dev/null 2>&1
     TEST_OK=$?
     CNT=$PROBE_TIME
     while [[ "$TEST_OK" != "0" &&  "$CNT" != "0"  ]]
     do
        echo -n "."
        sleep 1
        CNT=$(( $CNT - 1 ))
        if [ "$CNT" = 0 ] ; then
          exit 99
        fi
        ifconfig  "$INTERFACE"  >> /dev/null 2>&1
        TEST_OK=$?
     done
  fi
}



# Load configfile

if [ -z  $1 ] || [ -z $2 ]; then
  echo "Usage piratebox_setup_wlan.sh my_config <start|stop|probe>"
  exit 1
fi


if [ !  -f $1 ] ; then
  echo "Config-File $1 not found..."
  exit 1
fi

#Load config
. $1


### Check config
if [ -z $INTERFACE ]; then
   echo "Please define i.e.  "
   echo "   INTERFACE=wlan0 "
   exit 1
fi

if [ -z $IP ] ; then
   echo "Please define i.e.  "
   echo "   IP=192.268.46.2 "
   exit 1
fi

if [ -z $NETMASK ] ; then
   echo "Please define i.e.  "
   echo "   NETMASK=255.255.255.0 "
   exit 1
fi



###  Do the stuff

if [ $2 =  "start" ] ; then

  echo "Bringing up wifi interface $INTERFACE "
  ifconfig $INTERFACE up

  if  [ $?  -ne 0 ] ; then
     echo  "..failed ";
     exit 1
  fi

  echo "Setting up $INTERFACE"
  ifconfig $INTERFACE  $IP netmask $NETMASK

  if  [ $?  -ne 0 ] ; then
     echo  "..failed ";
     exit 1
  fi

  if [ $IPV6_ENABLE = "yes" ] ; then
     echo  "Setting up IPv6 stuff"
     IPv6="$IPV6_IP"/"$IPV6_MASK"
     echo  "  $INTERFACE  -->$IPv6<--"
     ifconfig $INTERFACE  add  $IPv6
     #That ip is a local IP only
     ip addr change  $IPv6   dev $INTERFACE  scope link
  fi

  . $NODE_CONFIG

  if [ "$NODE_CONFIG_ACTIVE" == "yes" ] && [ "$NODE_IPV6_SET_IP" == "yes" ]; then
	echo "Setting up IPv6 Mesh-Node IP on interface $NODE_INTERFACE"
	ifconfig $NODE_INTERFACE add $NODE_IPV6_IP"$NODE_IPV6_MASK"
  fi

elif [ $2 = "stop" ] ; then
  echo "Stopping wifi interface $INTERFACE "
  ifconfig $INTERFACE down

  if [ "$NODE_CONFIG_ACTIVE" == "yes" ] && [ "$NODE_IPV6_SET_IP" == "yes" ] ; then
	echo "Removing the Node-Address again..."
        ifconfig $NODE_INTERFACE del $NODE_IPV6_IP"$NODE_IPV6_MASK"
  fi
elif [ $2 = "probe" ] ; then
   # simply check if the interface is available
   probe
fi



