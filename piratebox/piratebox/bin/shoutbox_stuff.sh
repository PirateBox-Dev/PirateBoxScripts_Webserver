#!/bin/sh

# Matthias Strubel - (c)2012-2014 with GPL-3
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
export SHOUTBOX_CLIENT_TIMESTAMP=$SHOUTBOX_CLIENT_TIMESTAMP

export DISK_GEN_HTMLFILE=$GEN_DISKFILE

#Writing init-message and reset chat..
if [ "$RESET_CHAT"  = "yes" ] ; then
   cat $PIRATEBOX_FOLDER/conf/chat_init.txt > $CHATFILE
fi

#Generate content file for Shoutbox
python psogen.py generate

if [ "$SHOUTBOX_ENABLED" = "no" ] ; then
        # If the shoutbox is disabled, we remove the writable flag
        echo -n "Making shoutbox readonly..."
        chmod a-w $CHATFILE
        echo "done"
fi

#Generate content file for DiskUsage
python diskusage.py generate

$( sleep 20 && touch $GEN_CHATFILE ) &

#Set correct permissions
chown $LIGHTTPD_USER:$LIGHTTPD_GROUP $SHOUTBOX_CHATFILE
chown $LIGHTTPD_USER:$LIGHTTPD_GROUP $SHOUTBOX_GEN_HTMLFILE
chmod ug+rw  $SHOUTBOX_CHATFILE
chmod ug+rw  $SHOUTBOX_GEN_HTMLFILE

#DiskUsage correct permissions
chown $LIGHTTPD_USER:$LIGHTTPD_GROUP $DISK_GEN_HTMLFILE
chmod ug+rw  $DISK_GEN_HTMLFILE
