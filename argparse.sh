#!/usr/bin/env bash

# This is a simple script that emulates the most basic functionality in the
# python's argparse library for bash. The script defines CL arguments that can
# be accessed throw global variables.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Copyright (c) 2018 Jimmy Aguilar Mena.
# email: kratsbinovish@gmail.com
# date: 06/03/2018

# Declare global variables, I would prefer some level of encapsulation here,
# but there is not time now.

set -e
nargs=0			           # number of total arguments (unused now)
opt_chars=""		       # chain to parse
declare -A ARGS		       # associative array for argument/value
declare -A LONG_ARGS	   # associative array for long_argument/value
declare -A MAP_LONG_ARGS   # associative array argument/long_argument
declare -A MAP_ARGS_LONG   # associative array long_argument/argument
declare -A HELP_ARGS	   # associative array for argument/help_string
declare -A MANDATORY	   # list for mandatory arguments
declare -A ARG_TYPE	       # list for mandatory arguments
declare -A ENUMS           # list of valid parameters for lists

VALID_TYPES="string int float bool path file enum timer array"

# Arguments type tests
# Receives the argument and the value
function argparse_check () {
	if [[ -z $2 ]] || [[ -z ${ARG_TYPE[$1]} ]]; then   # Check
		printf "Error using %s function" $0 >&2
		exit 1
	fi
	local type=${ARG_TYPE[$1]}
	local value=$2
	local found="invalid"
	case $type in
		string) found=$value ;;
		int) [[ $value =~ (^-?[0-9]+$) ]] && found=${BASH_REMATCH[1]} ;;
		float) [[ $value =~ (^-?[0-9]+.?[0-9]+?$) ]] && found=${BASH_REMATCH[1]} ;;
		bool) [[ $value =~ (^true$|^false$) ]] && found=${BASH_REMATCH[1]} ;;
		path) [[ -d $value ]] && found=$value ;;
		file) [[ -f $value ]] && found=$value ;;
		enum) [[ $value =~ (^${ENUMS[$1]//,/'$|^'}$) ]] && found=${BASH_REMATCH[1]} ;;
		timer) [[ $value =~ (^[0-9]+:?[0-5][0-9]:[0-5][0-9]$) ]] && found=${BASH_REMATCH[1]} ;;
		array) [[ $value =~ ^(([0-9]+,)+?[0-9]+)$ ]] && found=${BASH_REMATCH[1]//,/ } ;;
		*) found="invalid" ;;
	esac

	echo ${found}
}

function add_argument() {
	# This function adds command line parameters

	if [[ -z $1 ]]; then   # Check
		printf "Usage %s -a argname -l longname -h helstring -d defaultvalue\n" $0 >&2
		exit 1
	fi

	local OPTIND # to save the index locally
	declare -A arg=([h]="No documented option")
	while getopts "a:l:h:d:t:e:" o; do # Read the function arguments -a mandatory
		case $o in
			a) arg[a]=${OPTARG} ;;	# argument
			l) arg[l]=${OPTARG} ;;	# long argument
			h) arg[h]=${OPTARG} ;;	# help
			d) arg[d]=${OPTARG} ;;	# default value
			t) arg[t]=${OPTARG} ;;	# expected type
			e) arg[e]=${OPTARG} ;;	# enum (if -t enum)
			*) echo "Unknown option $o" >&2
		esac
	done

	if [ -n ${arg[a]} ]; then		# a short option is mandatory (-a before), check it
		opt_chars+=${arg[a]}		# append option to the format
		local def_val="empty"		# default is always false
		ARG_TYPE[${arg[a]}]=string	# Argument type, default string for all=
		MANDATORY[${arg[a]}]=true	# Arguments mandatory by default

		# Set type (default string)
		if [[ -n ${arg[t]} ]]; then
			if [[ ${VALID_TYPES} =~ ${arg[t]} ]]; then
				ARG_TYPE[${arg[a]}]=${arg[t]}
			else
				echo "${arg[t]} is not a valid type" >&2
				exit 1
			fi
		fi

		# Default values (default empty, false for bool)
		if [[ ${ARG_TYPE[${arg[a]}]} = "bool" ]]; then
			# bool values never mandatory, only true or false
			[[ -n ${arg[d]} ]] && def_val=true || def_val=false
			MANDATORY[${arg[a]}]=false
		else
			# Sets ENUMS[short] before testing. Needed!!
			if [[ ${ARG_TYPE[${arg[a]}]} = "enum" ]]; then
				if [[ -n ${arg[e]} ]] ; then
					ENUMS[${arg[a]}]=${arg[e]}
				else
					echo "Enum requires -e option" >&2
					exit 1
				fi
			fi
			# if default value provided use it else it is mandatory
			opt_chars+=":"
			if [[ -n ${arg[d]} ]]; then
				local default_value=$(argparse_check ${arg[a]} ${arg[d]})
				if [[ ${default_value} = "invalid" ]]; then
				   echo "Default value \"${arg[d]}\" for \"${arg[a]}\" is not \"${ARG_TYPE[${arg[a]}]}\" " >&2
				   echo "This is an error in the script"
				   exit 1
				else
					def_val=${default_value}
					MANDATORY[${arg[a]}]=false
				fi
			fi
		fi

		# assign always a value (empty if not)
		ARGS[${arg[a]}]=${def_val}			# add the vale in the array!!

		# the long option
		if [[ -n ${arg[l]} ]]; then
			LONG_ARGS[${arg[l]}]=${def_val}
			MAP_LONG_ARGS[${arg[a]}]=${arg[l]}	# for forward search fast
			MAP_ARGS_LONG[${arg[l]}]=${arg[a]}	# for backward search fast
		fi

		#always set a Help, at least say is empty
		HELP_ARGS[${arg[a]}]=${arg[h]}
	else
		echo "Error adding CL argument, no short name given" >&2
		exit 1
	fi

	((nargs+=1))  # Counter (unused now)
}

function parse_args() {
	# This function parses the command line arguments
	# for example should be called as: parse_args "$@"

	local largs=${MAP_LONG_ARGS[@]}        # create a string with all the long args
	local OPTIND                           # local index
	local short="" long=""

	while getopts ${opt_chars}"-:" o; do   # parse -short and --long options

		[[ $o = "?" ]] && continue         # assert is a valid option
		value="empty"

		if [[ $o = "-" ]]; then            # long options filtered by hand
			opt=${OPTARG}
			[[ ${opt} =~ "=" ]] && value=${opt#*=} && opt=${opt%=$value}  # split
			[[ -z $value ]] && value="empty"    # empty value means empty

			if [[ ${largs} =~ ${opt} ]]; then   # check if long option exists
				short=${MAP_ARGS_LONG[$opt]}    # corresponding short opt
				long=${opt}
			else                           # if no long option exist with this name
				echo "Unknown option: "$opt >&2
				continue
			fi
		else                               # short options (already filtered)
			short=$o                       # set them
			[[ ${opt_chars} =~ ${short}":" ]] && value=$OPTARG

			long=${MAP_LONG_ARGS[$o]}      # search if exists corresponding long
		fi

		# type validation here if needed
		if [[ ${ARG_TYPE[$short]} = "bool" ]]; then
			[[ ${ARGS[$short]} = true ]] && value=false || value=true
		fi

		local parsed_value=$(argparse_check ${short} ${value})
		if [[ ${parsed_value} = "invalid" ]]; then
			echo -n "Invalid value \"${parsed_value}\" for option \"-${short}\": "
			if [[ ${ARG_TYPE[${short}]} = "enum" ]]; then
				echo -e "valid values are:\n\t${ENUMS[${short}]}"
			else
				echo "it is not a valid \"${ARG_TYPE[${short}]}\" " >&2
			fi
			echo -e "\tKept value: ${ARGS[${short}]}" >&2
		else
			# assign
			ARGS[$short]=${parsed_value}           # if we arrive here always set a value
			[[ -n ${long} ]] && LONG_ARGS[$long]=${parsed_value}  # set long IF it exists
		fi

	done
	shift $((OPTIND-1))

	# Check mandatory arguments after all parse
	local invalid=0
	for i in "${!MANDATORY[@]}"; do
		if [[ ${ARGS[$i]} = empty ]] && [[ ${MANDATORY[$i]} = true ]]; then
			echo "Argument: -$i|--${MAP_LONG_ARGS[$i]}: ${HELP_ARGS[$i]}. is mandatory!!" >&2
			((invalid+=1))
		fi
	done

	if (( invalid > 0 )) ; then
		echo "Error: ${invalid} mandatory command line arguments missing" >&2
		exit 1
	fi

	# Assign rest of arguments in ARGS[REST][1] ARGS[REST][2]...
	ARGS["REST"]=$@
}

function printargs() {
	# Prints the arguments (short and long) with its values and doc-string 
	# The first argument is set as a prefix for every line
	local prefix=$1
	for i in "${!ARGS[@]}"; do
		local bo=" " bc=" "
		local long="--" def=""

		[[ "${MANDATORY[$i]}" = false ]] && bo="[" && bc="]"
		local short=${bo}-${i}${bc}

		[[ -n ${MAP_LONG_ARGS[$i]} ]] && long="|${bo}--${MAP_LONG_ARGS[$i]}${bc}"

		echo -e "${prefix}arg: ${short}${long}: (${ARG_TYPE[$i]}:${ARGS[$i]}) ${HELP_ARGS[$i]} "
	done
}
