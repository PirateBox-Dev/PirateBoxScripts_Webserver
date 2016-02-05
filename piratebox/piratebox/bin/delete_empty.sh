#!/bin/sh

# This script is needed for Piratebox on OpenWrt.
#   The find utility there has only a limited feature set.

IFS='
'


# Change directory, if not exist exit to not cleanup the 
#  OS filesystem.
cd $1   || exit 1

ls_list=$( find ./ -type f )

for filename in $ls_list  
do
   if [ ! -s $filename ] ; then
      echo "Deleting 0 Byte file $filename"
      rm $filename
   fi
done
