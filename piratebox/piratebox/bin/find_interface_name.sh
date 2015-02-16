#!/bin/sh

. /opt/piratebox/conf/piratebox.conf

module_enabled="${PIRATEBOX_FOLDER}/bin/piratebox_modules.sh enabled"

## Reads the following module configuration and 
##   tries to find out, which interface name is relevant for
##   the caller, based upon given parameters.

###   1st 	Parameter :   Caller Type  ( service | network )
###   2nd Parameter:    Callers's variable

## During processing the folowing module configuration is loaded
##	bridge.conf
##	network.conf
##	hostap.conf

RC=255
RESULT_VALUE=""


check_bridge(){
	local ok=1
	 $module_enabled "bridge_add_wifi"  && ok=0
	 $module_enabled "bridge_create"      && ok=0
	 return $ok
}

do_bridge_check(){
	# Only detect correct interface, when own variable not set (default)	
	if   check_bridge  ; then
		. "${MODULE_CONFIG}/bridge.conf"
		RESULT_VALUE="$BRIDGE_NAME"
		RC=0
	fi
	return $RC

}

test_for_interface(){
	local i_type="$1"
	local i_var="$2"

	if [ -n "$i_var" ] ; then
		RESULT_VALUE="$i_var"
		RC=0
		return 0
	fi

	if  ! do_bridge_check  ; then
		if [ "$i_type" = "service" ] ; then
			. "${MODULE_CONFIG}/network.conf"
			test_for_interface "network" "$IFCONFIG_INTERFACE"
		fi
		if [ "$i_type" = "network" ] ; then
			. "${MODULE_CONFIG}/hostap.conf"
			if  $module_enabled "hostap" && [ -n "$HOSTAP_INTERFACE" ]  ; then
				RESULT_VALUE="$HOSTAP_INTERFACE"
				RC=0
			fi
		fi
	fi
		
}


test_for_interface "$1"  "$2"

if [ "$RC" = "0" ] ; then
	echo $RESULT_VALUE
else
	echo "ERROR: No valid interface could be found"
fi

exit $RC
