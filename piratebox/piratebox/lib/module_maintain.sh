#!/bin/sh

MODULE_LIST=""

# Opmode Prefixes
PREFIX_START="S"
PREFIX_STOP="K"

_get_prefix_for_start(){
	echo $PREFIX_START
}
_get_prefix_for_stop(){
	echo $PREFIX_STOP
}


_work_on_module_(){
	local op_mode="$1"
	local module="$2"

	abort_start=0
	echo "Working on $module"
	_load_configuration_ "$module"
	[[ "$?" == 0 ]]  && "func_${module}_${op_mode}"
      return "$?"

}

#Processes all modules.enabled
auto_process_all() {
	local op_mode="$1"

	clean_exit=1
	abort_start=0

	for module in  $MODULE_LIST
	do
		_work_on_module_  "${op_mode}" "${module}"
		[[ "${abort_start}" == "1" ]] && return 99
	done

	return 0
}

_load_configuration_(){
	local module_name="$1"

	$DEBUG && echo "Loading configuration for ${module_name}"
	local config_list=$( func_"${module_name}"_get_config ) 
	$DEBUG && echo "  ... $config_list"
	
	for config_file in "$config_list" ; do
		if  echo "$config_file" | grep -q "/" ; then
			$DEBUG && echo "  .. absolude config path."
			. $config_file
		else
			$DEBUG && echo  "  .. module config."
			. "${MODULE_CONFIG}/${config_file}"  || return 99
		fi
	done
	return 0
}

_load_modules_() {
	local module_path=$1 

	local search_prefix=$( _get_prefix_for_$op_mode )
	local available_module_files=$(cd "${cfg_modules}/" && ls -x "${search_prefix}"??_* )

	 $DEBUG  && echo "modules_folder $cfg_modules "
	 $DEBUG  && echo "ls result: $available_module_files"

	

	for this_module in $available_module_files
	do
		echo -n  "Loading module $this_module .."
		. $cfg_modules/$this_module
		echo "done"
	done

	echo "Available modules: $MODULE_LIST "

	return 0
}

_run_single_(){
	local module_name="$1"
	local op_mode="$2"
	
	 $DEBUG  && echo "Loading Module $module_name"
	. $cfg_modules/$module_name
	 $DEBUG  && echo ".. Processing $module_name $op_mode"
	exit _work_on_module_ "$op_mode" "$module_name"
}

_run_() {
	MODULE_LIST=""
	local op_mode="$1"

	clean_exit=1

	# check if $cfg_modules is available
	if [ ! -d $cfg_modules ] ; then
		echo "config module folder $cfg_modules does not exists"
		exit 1
	fi

	# load modules
	_load_modules_  "$op_mode" || exit $?

	# Run configuration
	auto_process_all "$op_mode" 

	
	if [[ "$clean_exit" == "1" ]] ; then
		#If we changed something we deliver 0 as RC, because
		#we did our work successfully
		return  0
	else
		#So, we haven't changed something, so, we inform with 
		#RC 1 as a hint
		return 255
	fi
}	

_enable_(){
	MODULE_LIST=""
	local module_name="$1"
	
	# check if $cfg_modules is available
	if [ ! -d $cfg_modules ] ; then
		echo "config module folder $cfg_modules does not exists"
		exit 1
	fi
	
	if [ ! -e $cfg_modules_lib/$module_name ] ; then
		echo "unknown module ${module_name}"
		exit 1
	fi
	
	 $DEBUG  && echo "Loading Module $module_name"
	.  $cfg_modules_lib/$module_name
 
	 local start_num=$( "func_${module_name}_get_start_order" )
	 local stop_num=$( "func_${module_name}_get_stop_order" )
	 
	 local linkname_start="${PREFIX_START}${start_num}_${module_name}"
	 local linkname_stop="${PREFIX_STOP}${stop_num}_${module_name}"

	cd $cfg_modules
		#TODO better way to make this relative linking working...
	ln -s "../modules.available/${module_name}"  "${linkname_start}"
	ln -s "../modules.available/${module_name}"  "${linkname_stop}"
}

_disable_(){
	local module_name="$1"
	cd $cfg_modules
	ls -1 ./???_$module_name  | xargs -I {} rm -v  {}

}
