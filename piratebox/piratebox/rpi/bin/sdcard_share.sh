#/bin/bash

# This script enables the SDCard as ext4  to be used as storage
# it also activates some spare for swap

MOUNTPOINT="/mnt/sdshare"
FS="ext4"


SDCARD="/dev/mmcblk0"

if test -e "$SDCARD"p3 ; then
    echo "ERROR: SWAP already exists"
    exit 1
fi

if test -e "$SDCARD"p4 ; then
    echo "ERROR: Data partition already exists"
    exit 1
fi

echo "Creating partitions.."
fdisk "$SDCARD" <<EOF
n
p
3

+256M
n
p
4


w


EOF

echo Reloading partition table
partprobe "$SDCARD"

if test -e  "$SDCARD"p3 ; then
    if test -e  "$SDCARD"p4 ; then
        echo "Ok, all partitions available"
    else
        echo "ERROR: Data partition is missing."
        exit 1
    fi
else
    echo "ERROR: SWAP missing."
    exit 1
fi

mkswap /dev/mmcblk0p3 
if [ $? -ne 0 ] ; then
    echo "Error formating swap"
    exit 1
fi

SWAP_UUID=$( blkid | grep "/dev/mmc*.*TYPE=\"swap\"" | egrep -o " UUID=\"([a-zA-Z0-9-])*\"" | sed 's/ //g' )

if grep -q "${SWAP_UUID}" /etc/fstab ; then
    echo "Error: swap is already configured in fstab"
    exit 1
fi

echo "Adding swap to fstab"
echo "${SWAP_UUID} none swap defaults 0 0" >> /etc/fstab 

echo "Creating data partition"
mkfs.ext4 -F "$SDCARD"p4 
if [ $? -ne 0 ] ; then
    echo "Error formating data"
    exit 1
fi

DATA_UUID=$( blkid | grep "${SDCARD}p4.*TYPE=\"ext4\"" | egrep -o " UUID=\"([a-zA-Z0-9-])*\"" | sed 's/ //g' )
if  grep -q "${DATA_UUID}" /etc/fstab ; then
    echo "Error: data is already configured in fstab"
    exit 1
fi

echo "${DATA_UUID} ${MOUNTPOINT} ext4 defaults,noatime,nodiratime,data=writeback 0 0 ">> /etc/fstab

mkdir -p "${MOUNTPOINT}"
mount "${MOUNTPOINT}"

if [ $? -ne 0 ] ; then
    echo "ERROR mounting data partion"
    exit 1
fi

echo "## Moving files..."
mv /opt/piratebox/share "${MOUNTPOINT}/share" > /dev/null 2>&1
ln -s "${MOUNTPOINT}/share" /opt/piratebox/share > /dev/null


# Force update diskwirte
touch -t 197001010101 /opt/piratebox/www/diskusage.html
wget http://127.0.0.1/cgi-bin/diskwrite.py -q -O -

exit 0

