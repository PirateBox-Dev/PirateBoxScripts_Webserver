#!/bin/sh

IFS='
'



cd $1
ls_list=$( ls -1 )

for filename in $ls_list  
do
   if [ ! -s $filename ] ; then
      echo "Deleting 0 Byte file $filename"
      rm $filename
   fi
done
