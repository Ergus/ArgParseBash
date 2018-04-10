README
======

This is a simple script and a test-program that emulates the argparse 
python-like functionality in bash.
You can call the script with the options specified using the long
and short names. For the usage, please, see the test examples scripts.

There are 4 functions:

+ add_argument: to add comman line options

	The command line arguments can be defined with 5 options:

	- -a short name for argument [mandatory]

	- -l long name for argument [optional default: ""]

	- -d default value [else, the argument becomes mandatory]

	- -h docstring [optional default: "Not documented"]

	- -b boolean [sets a boolean variable default false if used without -d]

+ parse_args: to parse the command line arguments or any list

	This one can be called passsing any list of arguments to process
	for example "$@"

+ printargs: prints the arguments defined in the script and the values.

	Usefull for debug purposes and to print the help

+ validate: Validates the arguments.

	Up to now it only check the mandatory options.
	This function is always called by default at the end of parse_args

Accessing parameters
--------------------

The values can be accessed throw the global arrays created as ARGS[short] or
LONG_ARGS[long].

The help can be accessed as HELP_ARGS[short].

There are names restrictions for the script variables as all the variables in bash are public by default. Also for simplicity, please read the script.

These names are forbidden because we use them internally and they are public variables.

+ ARGS: asociative array with the values, index *short* name

+ LONG_ARGS: asociative array with the values, index *long* name

+ MAP_LONG_ARGS: Map from *short* to *long* names

+ MAP_ARGS_LONG: Map from *long* to *short* names

+ HELP_ARGS: Help string arrays. Index *short*

+ MANDATORY: Array that returns is the argument is mandatory

+ ARG_TYPE: Array that returns the argument type

This is a WIP and of course can be improved, if you use/improve it
or you find any error/issue, please, contact me in order to improve,
correct or add you as a collaborator in this project.


The bool variables added with -b do not require a parameter, in fact it is ignored if provided and the variable is only switched between true and false.

This is under GPLv3 license

**author:** Jimmy Aguilar Mena

**email:** kratsbinovish@gmail.com

**date:** 06/03/2018
