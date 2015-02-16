#!/bin/sh

#  This script enables a sort of timerescue System
#  for Systems without a Realtime Clock
#  like TP-Link MR3020 , RaspberryPI
#
#  It does not reflect the real time, but 
#  gives a sort of stability to complete standalone 
#  systems.
#
#  Licenced under GPL-3  @ 2012-2014
#    Matthias Strubel    matthias.strubel@aod-rgp.de

##function for similar saving & getting time
get_datetime() {
	date +%C%g%m%d%H%M  
}


# Load configfile

if [ -z $1 ] ; then
  echo "Set up a crontab entry for regulary saving the time"
  echo "Usage $0  <step>"
  echo "    Valid steps are:"
  echo "       install    - installs the needed parts into crontab"
  echo "       save       - saves time into file"
  echo "       recover    - recovers the time from a file"

  exit 1
fi


. /opt/piratebox/conf/piratebox.conf

. $PIRATEBOX_FOLDER/conf/modules_conf/timesave.conf

if [ "$2" = "install" ] ; then
    crontab -l   >  $PIRATEBOX_FOLDER/tmp/crontab 2> /dev/null
    echo "#--- Crontab for PirateBox-Timesave" >>  $PIRATEBOX_FOLDER/tmp/crontab
    echo " */5 * * * *   $PIRATEBOX_FOLDER/bin/timesave.sh save "  >> $PIRATEBOX_FOLDER/tmp/crontab
    crontab $PIRATEBOX_FOLDER/tmp/crontab

    echo  "initialize timesave file"
    touch $TIMESAVE
    chmod a+rw $TIMESAVE
    get_datetime  > $TIMESAVE


    echo "Remember MAY have to cron active..."
    echo "  on OpenWrt run:  /etc/init.d/piratebox enable"
 
    exit 0
fi

if [ "$2" = "save" ] ; then
    if [ -e $TIMESAVE ] ; then
	if [ `get_datetime` -lt  `cat $TIMESAVE` ] ; then
		 logger -s "$0 : sorry, current date-time is lower then saved one, don't save it this time"
		 exit 1
	fi
    fi

    #Save Datetime in a recoverable format...
    get_datetime  > $TIMESAVE
    exit 0
fi

if [ "$2" = "recover" ] ; then
    if [ `get_datetime` -lt  `cat $TIMESAVE` ] ; then
	    date  `cat $TIMESAVE `
	    [ "$?" != "0" ] &&  echo "error in recovering time" && exit 255
	    echo "Time recovered"
	    exit 0
    else
	   echo "Sorry, changing timebackward via timesave is not possible"
	   exit 1
    fi
fi

