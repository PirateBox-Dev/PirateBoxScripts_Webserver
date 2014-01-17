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


#Writing init-message and reset chat..
if [ "$RESET_CHAT"  = "yes" ] ; then
   cat $PIRATEBOX_FOLDER/conf/chat_init.txt > $CHATFILE
fi

#Generate content file
python psogen.py generate

if [ "$SHOUTBOX_ENABLED" = "no" ] ; then
        # If the shoutbox is disabled, we remove the writable flag
        echo -n "Making shoutbox readonly..."
        chmod a-w $CHATFILE
        echo "done"
fi

#Set correct permissions
chown $LIGHTTPD_USER:$LIGHTTPD_GROUP $SHOUTBOX_CHATFILE
chown $LIGHTTPD_USER:$LIGHTTPD_GROUP $SHOUTBOX_GEN_HTMLFILE



