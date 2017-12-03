#!/bin/bash
# On/Off/Reboot button feature
# via https://forum.piratebox.cc/read.php?7,21068,21068#msg-21068
pin=9
gpio mode $pin in
gpio mode $pin up
counter=0
while true; do
 var=$(gpio read $pin)
 if [ "$var" -eq "0" ] ; then
		echo Button has been pressed..
		echo ""
		sleep 1
		((counter = counter + 1))
		if [ "$counter" -gt "10" ] ; then
		  echo Shutting Down..
		  sudo shutdown -h now
		fi
 else
		if [ "$counter" -gt "3" ] ; then
			echo Rebooting..
			sudo shutdown -r now
		fi
		counter=0
 fi
sleep 0.1
done
