#!/bin/sh
# Matthias Strubel , 2013-2015 (c) GPL-3
#   matthias.strubel@aod-rpg.de


## This is an obsolete feature. 
##  we exit that stuff only and skip processing it.
##  In 99% this breaks stuff, over helping you.
##  Will be removed with the next full release.

echo "exchange_www.sh - was deactivated and does nothing now."
echo "                  Will be removed with the next full release."
exit 0


# Move www folder to given destination

# Load configfile

if [ -z  $1 ] || [ -z $2 ]; then 
  echo "Usage change_www my_config <destination>
      i.e. # exchange_www.sh /opt/piratebox/conf/piratebox.conf  /mnt/usb/PirateBox/www_alt  "
      exit 1
fi


if [ !  -f $1 ] ; then 
  echo "Config-File $1 not found..." 
  exit 1 
fi

#Load config
. $1 

      echo "----------------------------------------------------"
      echo "####          $2                ####"
      echo "####         switching directories              ####"
      echo "----------------------------------------------------"

      mv  $WWW_FOLDER  $PIRATEBOX_FOLDER/www_old 
      ln -sf   $2  $WWW_FOLDER
      echo "  Copy over >>fake internet detection-stuff<<"
      cp -v  $PIRATEBOX_FOLDER/www_old/ncsi.txt $WWW_FOLDER
      cp -rv $PIRATEBOX_FOLDER/www_old/library  $WWW_FOLDER
      echo "  Copy over >>redirect.html<< for automatic redirect on  wrong entered page<<"
      cp -v  $PIRATEBOX_FOLDER/www_old/redirect.html $WWW_FOLDER
      echo "  Done. Now, you are on your own! "
