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
   echo $CHATMSG > $CHATFILE
fi

#Generate content file
python psogen.py generate

#Set correct permissions
chown $LIGHTTPD_USER:$LIGHTTPD_GROUP $SHOUTBOX_CHATFILE
chown $LIGHTTPD_USER:$LIGHTTPD_GROUP $SHOUTBOX_GEN_HTMLFILE


if [ "$GLOBAL_CHAT" = "yes" ] ; then
     export SHOUTBOX_BROADCAST_DESTINATIONS=$GLOBAL_DEST
     LIGHTTPD_ENV_BR_LINE="   \"SHOUTBOX_BROADCAST_DESTINATIONS\" => \"" $SHOUTBOX_BROADCAST_DESTINATIONS\" " , "
fi

LIGHTTPD_ENV="setenv.add-environment = ( 
   \"PYTHONPATH\"             => \"$PYTHONPATH:$PIRATEBOX/python_lib\", 
   \"SHOUTBOX_GEN_HTMLFILE\"  => \"$SHOUTBOX_GEN_HTMLFILE\" ,
   \"SHOUTBOX_CHATFILE\"      => \"$SHOUTBOX_CHATFILE\" ,
   $LIGHTTPD_ENV_BR_LINE 

  )"



echo "$LIGHTTPD_ENV" >  $PIRATEBOX_FOLDER/conf/lighttpd/env

