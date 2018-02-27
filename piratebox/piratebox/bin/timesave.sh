#!/bin/sh

#  This script enables a sort of timerescue System
#  for Systems without a Realtime Clock
#  like TP-Link MR3020 , RaspberryPI
#
#  It does not reflect the real time, but
#  gives a sort of stability to complete standalone
#  systems.
#
#  Licenced under GPL-3  @ 2012,2017
#    Matthias Strubel    matthias.strubel@aod-rgp.de

# Print usage if parameters are not provided
if [ -z "$1" ] || [ -z "$2" ] ; then
  echo "Set up a crontab entry for regulary saving the time"
  echo "Usage $0 <path to piratebox.conf> <step>"
  echo "    Valid steps are:"
  echo "       install    - installs the needed parts into crontab"
  echo "       save       - saves time into file"
  echo "       recover    - recovers the time from a file"

  exit 1
fi

# Load configfile
. "$1"

if [ "$2" = "install" ] ; then
  crontab -l > "$PIRATEBOX_FOLDER/tmp/crontab" 2> /dev/null
  echo "#--- Crontab for PirateBox-Timesave" >> "$PIRATEBOX_FOLDER/tmp/crontab"
  echo " */5 * * * * $PIRATEBOX_FOLDER/bin/timesave.sh $PIRATEBOX_FOLDER/conf/piratebox.conf save" >> "$PIRATEBOX_FOLDER/tmp/crontab"
  crontab "$PIRATEBOX_FOLDER/tmp/crontab"

  echo "initialize timesave file"
  touch "$TIMESAVE"

  echo "Remember MAY have to cron active..."
  echo "  on OpenWrt run: /etc/init.d/cron enable"

  exit 0
fi

# Save current date-time in a recoverable format
if [ "$2" = "save" ] ; then
  if [ -e "$TIMESAVE" ] ; then
    curtime="$(date +%s)"
    recovertime="$( date -r "$TIMESAVE"  +%s )"
    if [  $curtime -lt $recovertime  ] ; then
      logger -s "$0: Current date-time is lower then saved one. Not saving!"
      exit 1
    fi
  fi

  touch "$TIMESAVE"
  exit 0
fi

# Recover date-time from a previous state
if [ "$2" = "recover" ] ; then
  curtime="$(date +%s)"
  recovertime="$( date -r "$TIMESAVE"  +%s )"
  if [  $curtime -lt $recovertime  ] ; then
    if date -s @$recovertime  > /dev/null ; then
      logger -s "$0: Sucessfully recovered date-time."
      exit 0
    else
      logger -s "$0: Could not recover date-time."
      exit 1
    fi
  else
    logger -s "$0: Time can not be changed to the past."
    exit 1
  fi
fi
