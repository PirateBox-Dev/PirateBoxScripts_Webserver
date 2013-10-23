#!/bin/sh

# Script for node name generation. 
#   Requires:
#	argument 1:  	HOST (hostname) 
#	argument 2: 	NODE_NAME
#	argument 3:     NODE_GEN
#-
#   Output in var NODE_GEN_OUTPUT
# 

generate_node_name() {
	local in_host=$1
	local in_node_name=$2
	local in_node_gen=$3

	local complete_node_name=$in_node_name"."$in_host

	if [ "$in_node_gen" = "no" ] ; then
        	complete_node_name=$in_node_name
	fi
     	if [ "$in_node_name" = "" ] ;  then
		complete_node_name=$in_host
	fi
	if [ "$complete_node_name" != "" ] ; then
		export NODE_GEN_OUTPUT=$complete_node_name
		return 0
	else
        	echo "Error: No valid node-name found"
		return 1
    	 fi
} 
