#!/bin/sh

#  This script enables a sort of timerescue System
#  for Systems without a Realtime Clock
#  like TP-Link MR3020 , RaspberryPI
#
#  It does not reflect the real time, but 
#  gives a sort of stability to complete standalone 
#  systems.
#
#  Licenced under GPL-2  @ 2012
#    Matthias Strubel    matthias.strubel@aod-rgp.de


# Load configfile

if [ -z  $1 ] || [ -z $2 ] ; then
  echo "Set up a crontab entry for regulary saving the time"
  echo "Usage $0 <path to piratebox.conf> <step>"
  echo "    Valid steps are:"
  echo "       install    - installs the needed parts into crontab"
  echo "       save       - saves time into file"
  echo "       recover    - recovers the time from a file"

  exit 1
fi

. $1

TIMESAVE="$PIRATEBOX_FOLDER/timesave_file"

if [ "$2" = "install" ] ; then
    crontab -l   >  $PIRATEBOX_FOLDER/tmp/crontab 2> /dev/null
    echo "#--- Crontab for PirateBox-Timesave" >>  $PIRATEBOX_FOLDER/tmp/crontab
    echo " */5 * * * *   $PIRATEBOX_FOLDER/bin/timesave.sh $PIRATEBOX_FOLDER/conf/piratebox.conf save "  >> $PIRATEBOX_FOLDER/tmp/crontab
    crontab $PIRATEBOX_FOLDER/tmp/crontab

    touch $TIMESAVE
    chmod a+rw $TIMESAVE

    if [  "$OPENWRT" = "yes" ] ; then
        echo "Placing Timerecover on Startup" 
        echo " $0 $1 recover " >> /etc/rc.local 
	sed  's:exit:#exit:g' -i /etc/rc.local 
        echo "Activating cron-service.."
	/etc/init.d/cron enable
	/etc/init.d/cron start
	echo "done"
    else 
       echo "Remember to have cron active..."
       echo "  on OpenWrt run:  /etc/init.d/cron enable"
       echo "                   /etc/init.d/cron start"
    fi
    #Save the current time
    $0 $1 "save"
    exit 0
fi

if [ "$2" = "save" ] ; then
    #Save Datetime in a recoverable format...
    date +%C%g%m%d%H%M  > $TIMESAVE
    exit 0
fi

if [ "$2" = "recover" ] ; then
    date  `cat $TIMESAVE `
    [ "$?" != "0" ] &&  echo "error in recovering time" && exit 255
    echo "Time recovered"
    exit 0
fi

