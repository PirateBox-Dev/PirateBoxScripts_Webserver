#!/bin/sh

#  Matthias Strubel (c) 2014  - GPL3
#  matthias.strubel@aod-rpg.de
#
#     This script deletes 0 Byte files

IFS='
'



cd $1
ls_list=$( find ./ )

for filename in $ls_list  
do
   if [ ! -s $filename ] ; then
      echo "Deleting 0 Byte file $filename"
      rm $filename
   fi
done
