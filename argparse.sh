#!/usr/bin/env bash

# This is a simple script that emulates the most basic functionality
# in the python's argparse library for bash.
# The script defines CL arguments that can be accessed throw global variables.
# It uses internally the getopts builtin bash function to allow arguments
# with spaces and optional arguments.
# This is a WIP and of course can be improved, if you use/improve it
# or you find any error/issue, please, contact me in order to improve,
# correct or add you as a collaborator in this project.
#
# This is under GPLv3 license
#
# author: Jimmy Aguilar Mena
# email: kratsbinovish@gmail.com
# date: 06/03/2018

# TODO: argument type validation
# TODO: default parameters

# Declare global variables, I would prefer some level of encapsulation here,
# but there is not time now.
nargs=0                       # number of total arguments (unused now)
opt_chars=""          		  # chain to parse
declare -A ARGS       	  # associative array for argument/value
declare -A LONG_ARGS  	  # associative array for long_argument/value
declare -A MAP_LONG_ARGS   # associative array argument/long_argument
declare -A MAP_ARGS_LONG   # associative array long_argument/argument
declare -A HELP_ARGS       # associative array for argument/help_string
declare -A MANDATORY       # list for mandatory arguments
declare -A ARG_TYPE        # list for mandatory arguments

function add_argument() {
	# This function adds command line parameters

	if [ -z $1 ]; then   # Check
		printf "Usage %s -a argname -l longname -h helstring -d defaultvalue\n" $0
		return
	fi

	local OPTIND # to save the index locally
	declare -A arg=([h]="No documented option")
	while getopts "a:l:h:d:b" o; do # Read the function arguments -a mandatory
		case $o in
			a) arg[a]=${OPTARG} ;;   				# argument
			l) arg[l]=${OPTARG} ;;   				# long argument
			h) arg[h]=${OPTARG} ;;   				# help
			d) arg[d]=${OPTARG}	;;   				# default value
			b) arg[b]=true	;;   				    # boolean
			*) echo "Unknown option "$o >&2
		esac
	done

	if [ -n ${arg[a]} ]; then # a short option is mandatory (-a before), check it
		opt_chars+=${arg[a]}                        # append option to the format
		local def_val=empty                         # default is always false
		# Argument type, default string for all
		ARG_TYPE[${arg[a]}]=string
		# Arguments not mandatory by default
		MANDATORY[${arg[a]}]=false

		# if [-b]=>bool then it does not expect an argument
		if [[ -n ${arg[b]// } ]]; then
			ARG_TYPE[${arg[a]}]=bool
			# any argument given only see true or false
			[[ -n ${arg[d]// } ]] && def_val=true || def_val=false
		else
			opt_chars+=":"
			# if default value provided use it else it is mandatory
			[[ -n ${arg[d]// } ]] && def_val=${arg[d]} || MANDATORY[${arg[a]}]=true
		fi

		# assign always a value (false if not)
		ARGS[${arg[a]}]=${def_val}             # add the vale in the array!!

		# the long option is optional
		if [[ -n ${arg[l]} ]]; then
			LONG_ARGS[${arg[l]}]=${def_val}
			MAP_LONG_ARGS[${arg[a]}]=${arg[l]}      # for forward search fast
			MAP_ARGS_LONG[${arg[l]}]=${arg[a]}      # for backward search fast
		fi

		#always set a Help, at least say is empty
		HELP_ARGS[${arg[a]}]=${arg[h]}
	else
		echo "Error adding CL argument, no short name given" >&2
	fi

	((nargs+=1))  # Counter (unused now)
}

function validate() {
	local success=true
	for i in "${!MANDATORY[@]}"; do
		# check mandatory arguments with a value
		if [[ ${ARGS[$i]} = empty ]] && [[ ${MANDATORY[$i]} = true ]]; then
			echo "Argument: -$i|--${MAP_LONG_ARGS[$i]}: ${HELP_ARGS[$i]}. is mandatory!!"
			success=false
		fi
	done
	if [ "${success}" = false ] ; then
		echo "Mandatory command line arguments missing" >&2
		exit 1
	fi
}

function parse_args() {
	# This function parses the command line arguments
	# for example should be called as: parse_args "$@"

	local largs=${MAP_LONG_ARGS[@]}      # create a string with all the long args
	local OPTIND                         # local index
	local short="" long=""

	while getopts ${opt_chars}"-:" o; do # parse -short and --long options

		[[ $o = "?" ]] && continue       # assert is a valid option
		value=empty

		if [[ $o = "-" ]]; then     # long options filtered by hand
			opt=${OPTARG}
			[[ ${opt} =~ "=" ]] && value=${opt#*=} && opt=${opt%=$value}  # split
			[[ -z $value ]] && value=empty        # empty value means empty

			if [[ ${largs} =~ ${opt} ]]; then     # check if long option exists
				short=${MAP_ARGS_LONG[$opt]}      # corresponding short opt
				long=${opt}
			else                    # if no long option exist with this name
				echo "Unknown option: "$opt >&2
				continue
			fi
		else                                   # short options (already filtered)
			short=$o                           # set them
			[[ ${opt_chars} =~ ${short}":" ]] && value=$OPTARG

			long=${MAP_LONG_ARGS[$o]}          # search if exists corresponding long
		fi

		# type validation here if needed
		if [[ ${ARG_TYPE[$short]} = "bool" ]]; then
			[[ ${ARGS[$short]} = true ]] && value=false || value=true
		fi

		# assign
		ARGS[$short]=${value}                 # if we arrive here always set a value
		[[ -n ${long} ]] && LONG_ARGS[$long]=${value}    # set long IF it exists

	done
	shift $((OPTIND-1))
	validate
}

function printargs() {
	# Prints the arguments (short and long) with its values and doc-string 
	for i in "${!ARGS[@]}"; do
		local bo=" " bc=" "
		local long="--" def=""

		[[ "${MANDATORY[$i]}" = false ]] && bo="[" && bc="]"
		local short=${bo}-${i}${bc}

		[[ -n ${MAP_LONG_ARGS[$i]} ]] && long="|${bo}--${MAP_LONG_ARGS[$i]}${bc}"

		echo -e "arg: ${short}${long}: (${ARG_TYPE[$i]}:${ARGS[$i]}) \t${HELP_ARGS[$i]} "
	done
}
