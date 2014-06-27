#!/bin/sh

# Starts deamon for global shoutbox service
#  requires  piratebox.conf as first parameter
#
#  Matthias Strubel - 2012-2014
#  Licenced with GPL-3

. $1

cd $PIRATEBOX_FOLDER
cd python_lib

export SHOUTBOX_CHATFILE=$CHATFILE
export SHOUTBOX_GEN_HTMLFILE=$GEN_CHATFILE


if [ "$GLOBAL_CHAT" = "yes" ] ; then
     export SHOUTBOX_BROADCAST_DESTINATIONS="$GLOBAL_DEST"
fi

exec python discover.py
