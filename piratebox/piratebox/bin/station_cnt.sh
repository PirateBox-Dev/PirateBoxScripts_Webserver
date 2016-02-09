#!/bin/sh

## By Matthias Strubel , Licenced by GPL-3 (c)2012-2014

CNT=`iw wlan0 station dump | grep Station | wc -l`
#DATE=`date`
#echo $DATE - $CNT
echo "<a title='Counter is refreshed every 2 minutes, you need to refresh the page'>Currently there are $CNT connected clients</a>"
