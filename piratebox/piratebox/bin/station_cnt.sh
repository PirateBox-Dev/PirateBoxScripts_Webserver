#!/bin/sh
CNT=`iw wlan0 station dump | grep Station | wc -l`
#DATE=`date`
#echo $DATE - $CNT
echo "Currently there are $CNT connected clients"
