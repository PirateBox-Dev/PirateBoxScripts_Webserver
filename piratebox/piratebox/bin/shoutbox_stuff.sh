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


#Writing init-message and reset chat..
if [ "$RESET_CHAT"  = "yes" ] ; then
   echo $CHATMSG > $CHATFILE
fi

#Generate content file
python psogen.py generate

#Set correct permissions
chown $LIGHTTPD_USER:$LIGHTTPD_GROUP $SHOUTBOX_CHATFILE
chown $LIGHTTPD_USER:$LIGHTTPD_GROUP $SHOUTBOX_GEN_HTMLFILE



