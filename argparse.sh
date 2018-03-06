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

# Declare global variables, I would prefer some level of encapsulation here,
# but there is not time now.
nargs=0                       # number of total arguments (unused now)
opt_chars=""          		  # chain to parse
declare -g -A ARGS       	  # associative array for argument/value
declare -g -A LONG_ARGS  	  # associative array for long_argument/value
declare -g -A MAP_LONG_ARGS   # associative array argument/long_argument
declare -g -A MAP_ARGS_LONG   # associative array long_argument/argument
declare -g -A HELP_ARGS       # associative array for argument/help_string

function add_argument(){
	# This function adds command line parameters

	if [ -z $1 ]; then   # Check
		printf "Usage %s -a argname -l longname -h helstring -d defaultvalue\n" $0
		return
	fi

	local OPTIND # to save the index locally
	declare -A arg=([h]="No documented")
	while getopts "a:l:h:d:" o; do # Read the function arguments -a mandatory
		case $o in
			a) arg[a]=${OPTARG} ;;   				# argument
			l) arg[l]=${OPTARG} ;;   				# long argument
			h) arg[h]=${OPTARG} ;;   				# help
			d) arg[d]=${OPTARG}	;;   				# default value
			*) echo "Unknown option "$o >&2
		esac
	done

	if [ -n ${arg[a]} ]; then # a short option is mandatory (-a before), check it
		opt_chars+=${arg[a]}                        # append option to the format
		local def_val=false                         # default is always false

		# an empty value is false and means bool argument
		[[ -n ${arg[d]// } ]] && opt_chars+=":" && def_val=${arg[d]}

		ARGS[${arg[a]}]=${def_val}                  # add the vale in the array!!

		if [[ -n ${arg[l]} ]]; then # the long option is optional
			LONG_ARGS[${arg[l]}]=${def_val}
			MAP_LONG_ARGS[${arg[a]}]=${arg[l]}      # for forward search fast
			MAP_ARGS_LONG[${arg[l]}]=${arg[a]}      # for backward search fast
		fi

		HELP_ARGS[${arg[a]}]=${arg[h]}  #always set a Help, at least say is empty
	else
		echo "Error adding CL argument, no short name given" >&2
	fi

	((nargs+=1))  # Counter (unused now)
}

function parse_args(){
	# This function parses the command line arguments
	# for example should be called as: parse_args "$@"

	local largs=${MAP_LONG_ARGS[@]}      # create a string with all the long args
	local OPTIND                         # local index

	while getopts ${opt_chars}"-:" o; do        # parse -short and --long options

		[[ $o = "?" ]] && continue              # assert is a valid option
		value=true                  # if a vale is touched here then default true

		if [[ $o = "-" ]]; then     # long options filtered by hand
			opt=${OPTARG}
			[[ ${opt} =~ "=" ]] && value=${opt#*=} && opt=${opt%=$value}  # split
			[[ -z $value ]] && value=false              # empty value means false

			if [[ ${largs} =~ ${opt} ]]; then # check if long option exists
				short=${MAP_ARGS_LONG[$opt]}            # corresponding short opt
				long=${opt}
				LONG_ARGS[$long]=${value}               # set long as it exists
			else                    # if no long option exist with this name
				echo "Unknown option: "$opt >&2
				continue
			fi

		else                                   # short options (already filtered)
			short=$o                           # set them
			[[ ${opt_chars} =~ ${short}":" ]] && value=$OPTARG

			long=${MAP_LONG_ARGS[$o]}          # search if exists corresponding long
			[[ -n ${long} ]] && LONG_ARGS[$long]=${value}    # set long IF it exists
		fi

		ARGS[$short]=${value}                 # if we arrive here always set a value

	done
	shift $((OPTIND-1))
}

function printargs(){
	# Prints the arguments (short and long) with its values and doc-string 

	for i in "${!ARGS[@]}"; do
		echo "arg: $i long: ${MAP_LONG_ARGS[$i]} help: ${HELP_ARGS[$i]} value: ${ARGS[$i]}"
	done
}
