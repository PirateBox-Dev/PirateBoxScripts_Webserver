#!/bin/sh

# ---- TEMPLATE ----

# Runs on every Startup after the normal init-steps are done
#  get config file 

if [ !  -f $1 ] ; then
  echo "Config-File $1 not found..."
  exit 255
fi

#Load config
. $1

# You can uncommend this line to see when hook is starting:
# echo "------------------ Running $0 ------------------"

