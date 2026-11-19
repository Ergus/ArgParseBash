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
nargs=0                    # number of total arguments (unused now)
opt_chars=""               # chain to parse
declare -A ARGS            # associative array for argument/value
declare -A MAP_LONG_ARGS   # associative array argument/long_argument
declare -A MAP_ARGS_LONG   # associative array long_argument/argument
declare -A HELP_ARGS       # associative array for argument/help_string
declare -A MANDATORY       # list for mandatory arguments
declare -A ARG_TYPE        # list for mandatory arguments
declare -A ENUMS           # list of valid parameters for lists
declare -a ARGS_REST=()    # remaining arguments, word boundaries preserved

VALID_TYPES="string int float bool path file enum timer list"

# Arguments type tests
# Receives the argument and the value
function argparse_check () {
	if (( $# != 2 )) || [[ -z ${ARG_TYPE[$1]} ]]; then   # Check; empty $2 is a valid value
		echo "Error using $0 function" >&2
		exit 1
	fi
	local type=${ARG_TYPE[$1]}
	local value=$2
	local found="invalid"
	case $type in
		string) found=$value ;;
		int) [[ $value =~ (^[+-]?[0-9]+$) ]] && found=${BASH_REMATCH[1]} ;;
		float) [[ $value =~ (^[+-]?[0-9]+(\.[0-9]*)?$) ]] && found=${BASH_REMATCH[1]} ;;
		bool) [[ $value =~ (^true$|^false$) ]] && found=${BASH_REMATCH[1]} ;;
		path) [[ -d $value ]] && found=$value ;;
		file) [[ -f $value ]] && found=$value ;;
		# Literal match: quoted pattern parts disable glob/regex metacharacters in values.
		enum) [[ $value != *,* && ",${ENUMS[$1]}," == *",${value},"* ]] && found=$value ;;
		timer) [[ $value =~ (^([0-9]+:)?[0-5][0-9]:[0-5][0-9]$) ]] && found=${BASH_REMATCH[1]} ;;
		list) [[ $value =~ ^(([0-9]+,)+?[0-9]+)$ ]] && found=${BASH_REMATCH[1]//,/ } ;;
		*) found="invalid" ;;
	esac

	# printf, not echo: values such as "-n" or "-e" would be taken as echo options.
	printf '%s\n' "${found}"
}

function add_argument() {
	# This function adds command line parameters

	if [[ -z $1 ]]; then   # Check
		echo "Usage $0 -a argname -l longname -h helstring -d defaultvalue" >&2
		exit 1
	fi

	local OPTIND # to save the index locally
	declare -A arg=([h]="No documented option")
	while getopts ":a:l:h:d:t:e:" o; do # Read the function arguments -a mandatory
		case $o in
			a) arg[a]=${OPTARG} ;;  # argument
			l) arg[l]=${OPTARG} ;;  # long argument
			h) arg[h]=${OPTARG} ;;  # help
			d) arg[d]=${OPTARG} ;;  # default value
			t) arg[t]=${OPTARG} ;;  # expected type
			e) arg[e]=${OPTARG} ;;  # enum (if -t enum)
			:) echo "${FUNCNAME[0]}: option -${OPTARG} requires a value" >&2; exit 1 ;;
			*) echo "${FUNCNAME[0]}: unknown option -${OPTARG}" >&2; exit 1 ;;
		esac
	done

	if [[ -n ${arg[a]} ]]; then       # a short option is mandatory (-a before), check it
		# getopts accepts only single-character names; ":", "-" and "?" are special to it.
		[[ ${arg[a]} =~ ^[a-zA-Z0-9]$ ]] || { echo "Error adding CL argument: invalid short name \"${arg[a]}\" (one letter or digit)" >&2; exit 1; }
		[[ -v ARG_TYPE[${arg[a]}] ]] && { echo "Error adding CL argument: -${arg[a]} already defined" >&2; exit 1; }
		[[ -n ${arg[l]} && -v MAP_ARGS_LONG[${arg[l]}] ]] && { echo "Error adding CL argument: --${arg[l]} already defined" >&2; exit 1; }
		opt_chars+=${arg[a]}        # append option to the format
		local def_val=""            # "" means unset; mandatory check relies on it
		ARG_TYPE[${arg[a]}]=string  # Argument type, default string for all=
		MANDATORY[${arg[a]}]=true   # Arguments mandatory by default

		# Set type (default string)
		if [[ -n ${arg[t]} ]]; then
			if [[ ${arg[t]} =~ ^(${VALID_TYPES// /|})$ ]]; then  # exact match only
				ARG_TYPE[${arg[a]}]=${arg[t]}
			else
				echo "${arg[t]} is not a valid type" >&2
				exit 1
			fi
		fi

		# Default values (default empty, false for bool)
		if [[ ${ARG_TYPE[${arg[a]}]} = "bool" ]]; then
			# bool values never mandatory, only true or false
			def_val=$(argparse_check "${arg[a]}" "${arg[d]:-false}")
			[[ ${def_val} != "invalid" ]] || { echo "Default value \"${arg[d]}\" for \"${arg[a]}\" is not \"bool\"" >&2; exit 1; }
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
				local default_value
				default_value=$(argparse_check "${arg[a]}" "${arg[d]}")
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
		ARGS[${arg[a]}]=${def_val}              # add the vale in the array!!

		# the long option
		if [[ -n ${arg[l]} ]]; then
			MAP_LONG_ARGS[${arg[a]}]=${arg[l]}  # for forward search fast
			MAP_ARGS_LONG[${arg[l]}]=${arg[a]}  # for backward search fast
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

	local OPTIND=1                         # local index
	local short="" long=""
	local rest=()

	# getopts stops at "--" and at the first non-option: "--" ends parsing,
	# a non-option goes to rest and parsing resumes after it.
	while (( OPTIND <= $# )); do
		[[ ${!OPTIND} = "--" ]] && { rest+=("${@:OPTIND+1}"); break; }
		getopts ":${opt_chars}-:" o || { rest+=("${!OPTIND}"); ((OPTIND+=1)); continue; }

		if [[ $o = "?" ]]; then
			echo "Unknown option: -${OPTARG}" >&2
			exit 1
		fi
		value=""

		if [[ $o = "-" ]]; then            # long options filtered by hand
			opt=${OPTARG}
			[[ ${opt} =~ "=" ]] && value=${opt#*=} && opt=${opt%="$value"}  # split

			if [[ -n ${opt} && -v MAP_ARGS_LONG[$opt] ]]; then  # exact match only
				short=${MAP_ARGS_LONG[$opt]}    # corresponding short opt
				long=${opt}
				# "--opt value": consume the next word, as getopts does for "-o value".
				if [[ ${OPTARG} != *=* && ${ARG_TYPE[$short]} != "bool" ]]; then
					if (( OPTIND > $# )); then
						echo "Option --$opt requires a value" >&2
						exit 1
					fi
					value=${!OPTIND}
					((OPTIND+=1))
				fi
			else                           # if no long option exist with this name
				echo "Unknown option: --$opt" >&2
				exit 1
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

		local parsed_value
		parsed_value=$(argparse_check "${short}" "${value}")
		if [[ ${parsed_value} = "invalid" ]]; then
			{
				echo -n "Invalid value \"${value}\" for option \"-${short}\": "
				if [[ ${ARG_TYPE[${short}]} = "enum" ]]; then
					echo -e "valid values are: [${ENUMS[${short}]}]"
				else
					echo -e "it is not a valid \"${ARG_TYPE[${short}]}\" "
				fi
			} >&2
			exit 1 # Abort when the parsed value was invalid
		else
			# assign
			ARGS[$short]=${parsed_value}           # if we arrive here always set a value
		fi

	done
	set -- "${rest[@]}"

	# Check mandatory arguments after all parse
	local invalid=0
	for i in "${!MANDATORY[@]}"; do
		if [[ -z ${ARGS[$i]} ]] && [[ ${MANDATORY[$i]} = true ]]; then
			echo "Argument: -$i|--${MAP_LONG_ARGS[$i]}: ${HELP_ARGS[$i]}. is mandatory!!" >&2
			((invalid+=1))
		fi
	done

	if (( invalid > 0 )) ; then
		echo "Error: ${invalid} mandatory command line arguments missing" >&2
		exit 1
	fi

	# ARGS[REST] joins words with spaces (kept for compatibility); ARGS_REST keeps them intact.
	ARGS_REST=("$@")
	if ! [[ $* =~ ^[[:blank:]]*$ ]]; then
		ARGS["REST"]=$*
		ARG_TYPE["REST"]=list
		HELP_ARGS["REST"]="REST of arguments"
		MANDATORY["REST"]=false
	fi
}

function printargs() {
	# Prints the arguments (short and long) with its values and doc-string
	# The first argument is set as a prefix for every line
	local prefix=$1
	for i in "${!ARGS[@]}"; do
		local bo=" " bc=" "
		local long=""
		local printval=${ARGS[$i]}

		[[ "${MANDATORY[$i]}" = false ]] && bo="[" && bc="]"
		local short="${bo}-${i}${bc}"

		[[ -n ${MAP_LONG_ARGS[$i]} ]] && long="|${bo}--${MAP_LONG_ARGS[$i]}${bc}"

		[[ ${ARG_TYPE[$i]} = list ]] && printval=\[${printval// /,}\] # Reformat list.

		echo -e "${prefix}arg: ${short}${long}: (${ARG_TYPE[$i]}:${printval}) ${HELP_ARGS[$i]} "

	done
}
