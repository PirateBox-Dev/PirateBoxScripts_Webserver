#!/bin/sh

# Matthias Strubel - 2012-09-15
#
# Only calls generate-Routing in piratebox-folder
#   gets Piratebox-Folder into www 


# $1  www folder
# $2  pirtatebox config file
 

. $2

cd $PIRATEBOX_FOLDER
cd python_lib

export SHOUTBOX_CHATFILE=$CHATFILE
export SHOUTBOX_GEN_HTMLFILE=$GEN_CHATFILE

python psogen.py generate

if [ "$GLOBAL_CHAT" = "yes"] ; then
     export SHOUTBOX_BROADCAST_DESTINATIONS=$GLOBAL_DEST
fi



