#!/bin/sh

# Matthias Strubel (c) 2013 - GPL3

convert_yn_to_tf(){
	local value=$1 ; shift
	if [ "$value" == "yes" ] ; then 
		echo "true"
	else
		echo "false"
	fi
}
