#!/bin/bash - 
#===============================================================================
#
#          FILE: piratebox.sh
# 
#         USAGE: systemctl piratebox start 
# 
#   DESCRIPTION: systemd file that piratebox.service points to. The systemd 
#+		 alternative to init.d
# 
#       OPTIONS: start stop restart
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Cale 'TerrorByte' Black (cablack@rams.colostate.edu) 
#  ORGANIZATION: 
#       CREATED: 02/02/2013 07:37:35 PM MST
#      REVISION:  0.2.0
#===============================================================================

#TODO Make ExecStop in service file kill dnsmasq, lighttpd, hostapd, droopy
#TODO Fully modular with new systemd standards
#TODO Add lock
set -o nounset                              # Treat unset variables as an error

# PATH for /opt piratebox folder
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin/:/usr/local/sbin:/opt/piratebox/bin

PIDFILE_DROOPY=/var/run/piratebox_droopy.pid
PIDFILE_HOSTAPN=/var/run/piratebox_hostapn.pid
PIDFILE_DNSMASQ=/var/run/piratebox_dnsmasq.pid
PIDFILE_LIGHTTPD=/opt/piratebox/tmp/lighttpd.pid
PIDFILE_SHOUTBOX=/opt/piratebox/tmp/shoutbox_daemon.pid

PIRATEBOX=/opt/piratebox
CONF=$PIRATEBOX/conf/piratebox.conf
#CONF_DROOPY=/opt/piratebox/conf/droopy.conf #not used
CONF_APN=$PIRATEBOX/conf/hostapd.conf

#Some extra config files for dnsmasq
CONF_DNSMASQ=$PIRATEBOX/conf/dnsmasq_generated.conf

CONF_LIGHTTPD=$PIRATEBOX/conf/lighttpd/lighttpd.conf

export PYTHONPATH=:$PYTHONPATH:$PIRATEBOX_PYTHONPATH

#Check for config file
if [ -f $CONF ] ; then
   . $CONF
else
   log_failure_msg "Configuration file not found"
   exit 1
fi

# Do basic initialization on non-openWRT Systems, too
if [ -f $PIRATEBOX/conf/init_done ] ; then
   INIT=OK
else
	$PIRATEBOX/bin/hooks/hook_pre_init.sh  "$CONF"
	$PIRATEBOX/bin/install_piratebox.sh "$CONF" part2
	$PIRATEBOX/bin/hooks/hook_post_init.sh  "$CONF"
	touch $PIRATEBOX/conf/init_done
fi

# Command Line for DNSMASQ,  use extra config file generated from command above
CMD_DNSMASQ="-x $PIDFILE_DNSMASQ -C $CONF_DNSMASQ "

# Carry out specific functions when asked to by the system
case "$1" in
  	start)
    	echo "Starting script piratebox "
    	echo ""

    	# Generate hosts & dnsmasq file
    	$PIRATEBOX/bin/generate_config_files.sh  "$CONF"
    	$PIRATEBOX/bin/hooks/hook_piratebox_start.sh  "$CONF"

	echo "Empty tmp folder"
    	find   $PIRATEBOX/tmp/  -exec rm {} \;

    	if [ "$DO_IW" = "yes" ] ; then
       		echo " Setting up Interface (iw) "
       		iw $PHY_IF interface add $INTERFACE type managed
    	fi

    	if [ "$DO_IFCONFIG" = yes ] ; then
      		echo "Setting up wlan"
      		#Setting up WLAN Interface
		#TODO Why not place the few lines from piratebox_setup_wlan.sh in here?
      		piratebox_setup_wlan.sh  $CONF start
    	fi
     	if  [ $? -ne 0 ] ;  then
       		echo "Failed setting up Interface"
     	else

       	# Only  activate
       	if  [ "$USE_APN" =  "yes" ] ;  then
         	echo "Starting hostap... "
         	/usr/sbin/hostapd --  $CONF_APN & #TODO Possible to change PIDFILE of hostapd?
        	if [ $? -ne 0 ]; then 
			echo $?
		fi
       	fi

      	#BRIDGE
      	if [ "$DO_BRIDGE" = "yes"  ] ; then
         	echo "Adding $INTERFACE to bridge $BRIDGE //  brctl addif $BRIDGE  $INTERFACE "
         	sleep 1
         	BR_CMD="brctl addif  $BRIDGE  $INTERFACE"
         	( $BR_CMD ; )
         	if [ $? -ne 0 ]; then
			echo $?
		fi
      	fi

       	if [ "$USE_DNSMASQ" = "yes" ] ;  then
         	echo  "Starting dnsmasq... "
   		# pidfile is written by dnsmasq
         	/usr/sbin/dnsmasq  --  $CMD_DNSMASQ  
         	if [ $? -ne 0 ]; then
            		echo $?
                fi	
       	fi


        if [ "$DROOPY_ENABLED" = "yes" ] ; then
          	#Start here the PirateBox-Parts droopy i.e.
          	#TODO More elegant way of doing this with: find -name 'file*' -size 0 -delete
		#Delete 0 Byte Files
          	delete_empty.sh  $UPLOADFOLDER
          	find  $UPLOADFOLDER/ -iname tmp\* -exec rm {} \;

          	DROOPY_USER=""
          	if [ "$DROOPY_USE_USER" = "yes" ] ; then
            		DROOPY_USER=" -c $LIGHTTPD_USER:$LIGHTTPD_GROUP "
          	fi
          	echo "Starting droopy..."
          	$PIRATEBOX/bin/droopy -- -H $HOST -d $UPLOADFOLDER -c "" -m "$DROOPY_TXT" $DROOPY_USERDIR  $DROOPY_PORT
          	echo $?
       	fi

       	#Do shoutbox stuff
       	$PIRATEBOX/bin/shoutbox_stuff.sh $WWW_FOLDER $CONF


       	#Start here the lighttpd i.e.
       	echo "Starting lighttpd..."
       	/usr/sbin/lighttpd -- -f $CONF_LIGHTTPD
       	if [ $? -ne 0 ]; then
        	echo $?
        fi

       	#Start Global Chat daemon if needed.
       	if [ "$GLOBAL_CHAT" = "yes" ] ; then
          	echo "Starting global chat service..."
          	$PIRATEBOX/bin/shoutbox_daemon.sh -- $CONF
          	if [ $? -ne 0 ]; then
                        echo $?
                fi
       	fi
fi

$PIRATEBOX/bin/hooks/hook_piratebox_start_done.sh  "$CONF"

;;
 
stop)
    	echo "Stopping script piratebox"
    	echo ""

     	$PIRATEBOX/bin/hooks/hook_piratebox_stop.sh  "$CONF"

    	if [  "$USE_APN"  = "yes" ] ;  then
       		echo  "Stopping hostapd... "
       		systemctl stop hostapd
       		if [ $? -ne 0 ]; then
                        echo $?
                fi
    	fi
    	
	if [ "$USE_DNSMASQ" = "yes" ] ;  then 
    	   	echo "Stopping dnsmasq..."
       		systemctl stop dnsmasq  
       		if [ $? -ne 0 ]; then
                        echo $?
                fi
    	fi

    	#Stop Global Chat daemon
    	if [ "$GLOBAL_CHAT" = "yes" ] ; then
          	echo "Stopping global chat service..."
          	kill $PIDFILE_SHOUTBOX #TODO better way?
          	if [ $? -ne 0 ]; then
                        echo $?
                fi
    	fi

    	echo "Stopping lighttpd..."
    	systemctl stop lighttpd
    	if [ $? -ne 0 ]; then
        	echo $?
        fi

    	if [ "$DROOPY_ENABLED" = "yes" ] ; then
       		#Kill Droopy
       		echo "Stopping droopy... "
       		pkill -9 -f python /opt/piratebox/bin/droopy
       		if [ $? -ne 0 ]; then
                        echo $?
                fi
    	fi

     	if [ "$DO_IFCONFIG" = yes ] ; then
       		piratebox_setup_wlan.sh $CONF stop
     	fi

     	if [ "$DO_IW" = "yes" ] ; then
        	iw dev $INTERFACE del
     	fi

     	# REMOVE BRIDGE
     	if [ "$DO_BRIDGE" = "yes"  ] ; then
         	echo "Remove Bridge..."
         	BR_CMD="brctl delif  $BRIDGE  $INTERFACE"
         	( $BR_CMD ; )
         	if [ $? -ne 0 ]; then
                        echo $?
                fi
     	fi

$PIRATEBOX/bin/hooks/hook_piratebox_stop_done.sh  "$CONF"


;;

restart)
	echo "Stopping script piratebox"
    	echo ""

     	$PIRATEBOX/bin/hooks/hook_piratebox_stop.sh  "$CONF"

    	if [  "$USE_APN"  = "yes" ] ;  then
       		echo  "Stopping hostapd... "
       		systemctl stop hostapd
       		if [ $? -ne 0 ]; then
                        echo $?
                fi
    	fi
    	
	if [ "$USE_DNSMASQ" = "yes" ] ;  then 
    	   	echo "Stopping dnsmasq..."
       		systemctl stop dnsmasq  
       		if [ $? -ne 0 ]; then
                        echo $?
                fi
    	fi

    	#Stop Global Chat daemon
    	if [ "$GLOBAL_CHAT" = "yes" ] ; then
          	echo "Stopping global chat service..."
          	kill $PIDFILE_SHOUTBOX #TODO better way?
          	if [ $? -ne 0 ]; then
                        echo $?
                fi
    	fi

    	echo "Stopping lighttpd..."
    	systemctl stop lighttpd
    	if [ $? -ne 0 ]; then
		echo $?
        fi

    	if [ "$DROOPY_ENABLED" = "yes" ] ; then
       		#Kill Droopy
       		echo "Stopping droopy... "
       		pkill -9 -f python /opt/piratebox/bin/droopy
       		if [ $? -ne 0 ]; then
                        echo $?
                fi
    	fi

     	if [ "$DO_IFCONFIG" = yes ] ; then
       		piratebox_setup_wlan.sh $CONF stop
     	fi

     	if [ "$DO_IW" = "yes" ] ; then
        	iw dev $INTERFACE del
     	fi

     	# REMOVE BRIDGE
     	if [ "$DO_BRIDGE" = "yes"  ] ; then
         	echo "Remove Bridge..."
         	BR_CMD="brctl delif  $BRIDGE  $INTERFACE"
         	( $BR_CMD ; )
         	if [ $? -ne 0 ]; then
                        echo $?
                fi
     	fi

$PIRATEBOX/bin/hooks/hook_piratebox_stop_done.sh  "$CONF"

### Now start ###

echo "Starting script piratebox "
    	echo ""

    	# Generate hosts & dnsmasq file
    	$PIRATEBOX/bin/generate_config_files.sh  "$CONF"
    	$PIRATEBOX/bin/hooks/hook_piratebox_start.sh  "$CONF"

	echo "Empty tmp folder"
    	find   $PIRATEBOX/tmp/  -exec rm {} \;

    	if [ "$DO_IW" = "yes" ] ; then
       		echo " Setting up Interface (iw) "
       		iw $PHY_IF interface add $INTERFACE type managed
    	fi

    	if [ "$DO_IFCONFIG" = yes ] ; then
      		echo "Setting up wlan"
      		#Setting up WLAN Interface
		#TODO Why not place the few lines from piratebox_setup_wlan.sh in here?
      		piratebox_setup_wlan.sh  $CONF start
    	fi
     	if  [ $? -ne 0 ] ;  then
       		echo "Failed setting up Interface"
     	else

       	# Only  activate
       	if  [ "$USE_APN" =  "yes" ] ;  then
         	echo "Starting hostap... "
         	/usr/sbin/hostapd --  $CONF_APN & #TODO Possible to change PIDFILE of hostapd?
         	if [ $? -ne 0 ]; then
                        echo $?
                fi
       	fi

      	#BRIDGE
      	if [ "$DO_BRIDGE" = "yes"  ] ; then
         	echo "Adding $INTERFACE to bridge $BRIDGE //  brctl addif $BRIDGE  $INTERFACE "
         	sleep 1
         	BR_CMD="brctl addif  $BRIDGE  $INTERFACE"
         	( $BR_CMD ; )
         	if [ $? -ne 0 ]; then
                        echo $?
                fi	
      	fi

       	if [ "$USE_DNSMASQ" = "yes" ] ;  then
         	echo  "Starting dnsmasq... "
   		# pidfile is written by dnsmasq
         	/usr/sbin/dnsmasq  --  $CMD_DNSMASQ  
         	if [ $? -ne 0 ]; then
                        echo $?
                fi
       	fi


        if [ "$DROOPY_ENABLED" = "yes" ] ; then
          	#Start here the PirateBox-Parts droopy i.e.
          	#TODO More elegant way of doing this with: find -name 'file*' -size 0 -delete
		#Delete 0 Byte Files
          	delete_empty.sh  $UPLOADFOLDER
          	find  $UPLOADFOLDER/ -iname tmp\* -exec rm {} \;

          	DROOPY_USER=""
          	if [ "$DROOPY_USE_USER" = "yes" ] ; then
            		DROOPY_USER=" -c $LIGHTTPD_USER:$LIGHTTPD_GROUP "
          	fi
          	echo "Starting droopy..."
          	$PIRATEBOX/bin/droopy -- -H $HOST -d $UPLOADFOLDER -c "" -m "$DROOPY_TXT" $DROOPY_USERDIR  $DROOPY_PORT
          	if [ $? -ne 0 ]; then
                        echo $?
                fi
       	fi

       	#Do shoutbox stuff
       	$PIRATEBOX/bin/shoutbox_stuff.sh $WWW_FOLDER $CONF


       	#Start here the lighttpd i.e.
       	echo "Starting lighttpd..."
       	/usr/sbin/lighttpd -- -f $CONF_LIGHTTPD
       	if [ $? -ne 0 ]; then
		echo $?
        fi

       	#Start Global Chat daemon if needed.
       	if [ "$GLOBAL_CHAT" = "yes" ] ; then
          	echo "Starting global chat service..."
          	$PIRATEBOX/bin/shoutbox_daemon.sh -- $CONF
          	if [ $? -ne 0 ]; then
                        echo $?
                fi
       	fi
fi

$PIRATEBOX/bin/hooks/hook_piratebox_start_done.sh  "$CONF"

;;
*)
	echo "Usage: /etc/init.d/piratebox {start|stop|restart}"
    	exit 1
    	;;
esac
exit 0
