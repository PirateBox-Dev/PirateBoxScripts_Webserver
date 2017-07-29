#!/bin/sh

# Find a vfat partition and configure it as an external share
MOUNTPOINT="/mnt/usbshare"
FS="vfat"
UUIDS=$(blkid | grep "/dev/sd*.*TYPE=\"${FS}\"" | egrep -o " UUID=\"([a-zA-Z0-9-])*\"" | sed 's/ //g')

if [ $(echo "${UUIDS}" | wc -l) -gt 1 ]; then
  echo "You seem to have more than one valid ${FS} partition for a USB share:"
  echo "${UUIDS}\n"
  echo "Please make sure you have a USB thumb drive attached with a single ${FS} partition."
  exit 1
fi

if [ $(echo "${UUIDS}" | wc -l) -lt 1 ] || [[ $UUIDS == "" ]]; then
  echo "You seem to have no valid ${FS} partition for a USB share."
  echo "Please make sure you have a USB thumb drive attached with a single ${FS} partition."
  exit 1
fi

UUID=$(echo "${UUIDS}" | cut -f2 -d" " | sed s/"\""/""/g)
grep "${UUID}" /etc/fstab > /dev/null
if [ $? -eq 0 ]; then
  echo "Error: This disk is already configured as an USB share..."
  exit 1
fi

echo "## Adding USB share..."
mkdir -p "${MOUNTPOINT}" > /dev/null
echo "${UUID} ${MOUNTPOINT} vfat umask=0,noatime,rw,user,uid=nobody,gid=nogroup 0 0" >> /etc/fstab
mount "${MOUNTPOINT}" > /dev/null

if [ $? == 0 ]; then
  echo "## Moving files..."
  mv /opt/piratebox/share "${MOUNTPOINT}/share" > /dev/null 2>&1
  ln -s "${MOUNTPOINT}/share" /opt/piratebox/share > /dev/null
else
  echo "Error: Mounting file system failed, will not move files..."
  cat "/etc/fstab"
fi

# Force update diskwirte 
touch -t 201701010101 /opt/piratebox/www/diskusage.html  
wget http://127.0.0.1/cgi-bin/diskwrite.py -q -O -

exit 0
