#!/bin/sh

PIRATEBOX_FOLDER=${PIRATEBOX_FOLDER:=/opt/piratebox}
PIRATEBOX_CONF="${PIRATEBOX_FOLDER}/conf/piratebox.conf"

. "${PIRATEBOX_CONF}"
. "${PIRATEBOX_FOLDER}/lib/module_maintain.sh"

## run to enable DEBUG mode:
# export DEBUG=true
DEBUG=${DEBUG:=false}

export cfg_modules=${MODULE_ENABLED}
export cfg_modules_lib=${MODULE_AVAILABLE}

case "$1" in
  start)
	_run_ "start"
    ;;
  stop)
  	_run_ "stop"
   ;;
  enable)
  	_enable_ "$2"
   ;;   
  disable)
  	_disable_ "$2"
   ;;      
#  module)
#  ;;
  *)
    echo "Usage: piratebox_modules.sh {start|stop}"
    echo "       piratebox_modules.sh enable module"
    echo "       piratebox_modules.sh disable module"
    exit 1
    ;;
esac

exit 0 