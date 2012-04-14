#!/bin/sh

# Author: Matthias Strubel   / Feb. 2011
#  Script for setting up the wlan interface
#  Parameter 1 i used for the config file providing the parameters

#   IP-Adress
#   Netmask
#   Interface

# Load configfile

if [ -z  $1 ] || [ -z $2 ]; then 
  echo "Usage piratebox_setup_wlan.sh my_config <start|stop>"
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

elif [ $2 = "stop" ] ; then
  echo "Stopping wifi interface $INTERFACE "
  ifconfig $INTERFACE down
fi
