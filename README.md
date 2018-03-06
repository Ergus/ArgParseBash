README
======

This is a simple script and a test-program that emulates the argparse 
python-like functionality in bash.
You can call the script with the options specified using the long
and short names. For the usage, please, see the test example script.

There are 3 functions:

+ add_argument: to add comman line options

	The command line arguments can be defined with 4 options:

	- -a short name for argument [mandatory]

	- -l long name for argument [optional default: ""]

	- -d default value [optional default: false]

	- -h docstring [optional default: "Not documented"]

+ parse_args: to parse the command line arguments or any list

	This one can be called passsing any list of arguments to process
	for example "$@"

+ printargs: prints the arguments defined in the script and the values.

	Usefull for debug purposes


The values can be accessed throw the global arrays created as ARGS[short] or 
LONG_ARGS[long].

The help can be accessed as HELP_ARGS[short].

This is a WIP and of course can be improved, if you use/improve it
or you find any error/issue, please, contact me in order to improve,
correct or add you as a collaborator in this project.

This is under GPLv3 license

**author:** Jimmy Aguilar Mena

**email:** kratsbinovish@gmail.com

**date:** 06/03/2018
