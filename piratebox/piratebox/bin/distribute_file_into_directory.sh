#!/bin/sh

#   matthias.strubel@aod-rpg.de
#
#  The following script is used to distribute a specific file into directories of the givien folder

directory=$1
src_file=$2
overwrite=$3
overwrite=${overwrite:=false}

# To enable DEBUG mode, run the following line before startint this script
#   export DEBUG=true
DEBUG=${DEBUG:=false}

TEST_RUN=false

filename="${src_file##*/}"

 $DEBUG && echo "filename: $filename"
 $DEBUG && echo "Overwrite mode : $overwrite "

if [ ! -e "$directory/$filename" ] || [ "$overwrite" = true ] ; then
	echo "Distribute $filename into $directory "
 	$DEBUG && echo "	cp $src_file $directory "
	$TEST_RUN ||  cp "$src_file" "$directory"  
else
	$DEBUG && echo "File exists"
fi


