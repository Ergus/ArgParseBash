README
======

This is a simple script and a test-program that emulates the argparse
python-like functionality in bash.

You can call the script with the options specified using the long
and short names. For the usage, please, see the test examples scripts.
[test_types.sh](test_types.sh)


There are 4 functions:

+ **add_argument**: to add comman line options.

	The command line arguments can be defined with 5 options:

	- **-a** short name for argument [mandatory]

	- **-l** long name for argument [optional default: ""]

	- **-d** default value [else, the argument becomes mandatory]. The
      default value is checked to assert they follow a valid regex to
      convert to the type.

	- **-h** docstring [optional default: "Not documented"]

	- **-t** Type of the parameters (string int float bool path file enum
      timer list) [optional default: string]

	- **-e** The list of valid values when using enum. The argument is
      used and required ONLY when -t enum. It expects a simple list
      like: **opt1,opt2 ...**

	  Ex: `add_argument -a e -l myenum -h "Enum option" -t enum -e option1,option2 -d option1`

+ **parse_args**: to parse the command line arguments or any list

	This one can be called passing any list of arguments to process
	for example: `parse_args "$@"`

	At the end of this function it checks that the mandatory arguments
    have a non-empty value.

	Every value is checked to assert they match a regex valid for
    their type.

+ **printargs**: prints the arguments defined in the script and the
  values.

	Useful for debug purposes and to print the help. This function can
    receive a parameter to add as a prefix before every printed line;
    this is useful to add comments before the printed lines:

	Example: `printargs #`

+ **argparse_check**: checks the values to match the parameter
  types. This is an internal function and the user shouldn't need to
  use it.

	The valid types are: (string int float bool path file enum timer list)

	In case of **path** and **file** it checks that the path or the
    file exists in the filesystem.

	In case of **float** it accepts formats like `3.14` or `3.`

	In case of **enum** if checks that the enum is one of the valid options.

	In case of **timer** the expected format is `H+:mm:ss`. `mm` and
    `ss` are limited to 00 -> 60. But `H+` means any valid positive
    integer.

	All the strings are valid but it is assumed that they don't
    contain spaces.

	In case of **list** currently the valid values are only integers
    and are set like `"1,2,34,56"` (quotes not required.)

Accessing parameters
--------------------

The values can be accessed throw the global arrays created as
`ARGS[short]` or `LONG_ARGS[long]`.

The help can be accessed as `HELP_ARGS[short]`.

There are names restrictions for the script variables as all the
variables in bash are public by default. Also, for simplicity, please
read the script.

These names are forbidden because we use them internally, and they are
public variables.

+ **ARGS**: associative array with the values, index *short* name. Ex: `${ARGS[e]}`

+ **LONG_ARGS**: associative array with the values, index *long* name. Ex: `${LONG_ARGS[myenum]}`

+ **MAP_LONG_ARGS**: Map from *short* to *long* names. Usually not needed by the user.

+ **MAP_ARGS_LONG**: Map from *long* to *short* names.  Usually not needed by the user

+ **HELP_ARGS**: Help string arrays. Index *short*.

+ **MANDATORY**: Array that returns is the argument is mandatory

+ **ARG_TYPE**: Array that returns the argument type

This is a WIP and of course can be improved, if you use/improve it
or you find any error/issue, please, contact me in order to improve,
correct or add you as a collaborator in this project.

The bool variables do not require a parameter, in fact it is ignored
if provided and the variable is only switched between true and
false. If you want to use a boolean variable that accepts `true` or
`false` y recommend to use an enum instead like:

```
add_argument -a b -l mybool -h "Bool option with input" -t enum -e true,false -d false
```

An extra **REST** argument is automatically added when some extra
command line arguments are added at the end of the input. This can be
accessed like: `ARGS[REST]` and in spite of it is not a list, it is
iterable or can be passed to other commands. Ex: `echo ${ARGS[REST]} |
wc -w` returns the number of elements (words) in the list.

Or:

```
for i in ${ARGS[REST]}; do
	echo $i
done
```

is also valid.

This is under GPLv3 license

**author:** Jimmy Aguilar Mena

**date:** 06/03/2018
