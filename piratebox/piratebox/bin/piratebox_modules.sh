#!/bin/sh

PIRATEBOX_FOLDER=${PIRATEBOX_FOLDER:=/opt/piratebox}
PIRATEBOX_CONF="${PIRATEBOX_FOLDER}/conf/piratebox.conf"

. "${PIRATEBOX_CONF}"
. "${PIRATEBOX_FOLDER}/lib/module_maintain.sh"

## run to enable DEBUG mode:
# export DEBUG=true
DEBUG=${DEBUG:=false}

export PYTHONPATH=:$PYTHONPATH:$PIRATEBOX_PYTHONPATH

export cfg_modules=${MODULE_ENABLED}
export cfg_modules_lib=${MODULE_AVAILABLE}

case "$1" in
  start)
	_run_ "start"
    ;;
  stop)
  	_run_ "stop"
   ;;
  restart)
  	_run_ "stop"
	_run_  "start"
   ;;      
 enable)
  	_enable_ "$2"
   ;;
  enabled)
  	 _enabled_ "$2"
	 exit $?
   ;;   
  disable)
  	_disable_ "$2"
   ;;      
  module)
	_run_single_ "$2" "$3"
  ;;
  *)
    echo "Usage: piratebox_modules.sh {start|stop|restart}"
    echo "       piratebox_modules.sh enable module    -enable for start"
    echo "       piratebox_modules.sh enabled module   -Test if it is enabled" 
    echo "       piratebox_modules.sh disable module  "
    echo "       piratebox_modules.sh module <name> {start|stop}  - start/stop a single module  "
    exit 1
    ;;
esac

exit 0 