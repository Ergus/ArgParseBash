README
======

This is a simple script and a test-program that emulates the argparse
python-like functionality in bash. It requires bash 4.3 or newer.

You can call the script with the options specified using the long
and short names. For the usage, please, see the test examples scripts.
[test_types.sh](test_types.sh)


There are 4 public functions and 1 internal function. On error, `add_argument` and `parse_args` print
a message on stderr and return 1; they never exit. The caller decides
how to handle the failure, for example:

```
add_argument -a i -l int -t int -d 1 || exit 1
parse_args "$@" || exit 1
```

+ **add_argument**: to add command line options.

	The command line arguments can be defined with 6 options:

	- **-a** short name for argument [mandatory]

	- **-l** long name for argument [optional default: ""]

	- **-d** default value [else, the argument becomes mandatory; bool
      arguments are never mandatory]. The default value is checked
      against the regex of the type.

	- **-h** docstring [optional default: "No documented option"]

	- **-t** Type of the parameters (string int float bool path file enum
      timer list) [optional default: string]

	- **-e** The list of valid values when using enum. The argument is
      used and required ONLY when -t enum. It expects a simple list
      like: **opt1,opt2 ...**

	  Ex: `add_argument -a e -l myenum -h "Enum option" -t enum -e option1,option2 -d option1`

+ **parse_args**: to parse the command line arguments or any list

	This one can be called passing any list of arguments to process
	for example: `parse_args "$@" || exit 1`

	At the end of this function it checks that the mandatory arguments
    have a non-empty value.

	Every value is checked against the regex of its type.

+ **printargs**: prints the arguments defined in the script and the
  values.

	Useful for debug purposes and to print the help. This function can
    receive a parameter to add as a prefix before every printed line;
    this is useful to add comments before the printed lines:

	Example: `printargs "# "`

+ **printhelp**: prints a usage line and one line per argument to
  stdout: names, type, help string, and the default value, the enum
  values or "mandatory".

	`parse_args` calls it for `-h` and `--help` unless the script defines
	either, then returns 1, so `parse_args "$@" || exit 1` stops the script.

+ **argparse_check**: checks the values to match the parameter
  types. This is an internal function and the user shouldn't need to
  use it.

	The valid types are: (string int float bool path file enum timer list)

	In case of **path** and **file** it checks that the path or the
    file exists in the filesystem.

	In case of **float** it accepts formats like `3.14` or `3.`

	In case of **enum** it checks that the value is one of the valid options.

	In case of **timer** the expected format is `[H+:]mm:ss`. `mm` and
    `ss` are limited to 00 -> 59. The optional `H+` means any
    non-negative integer.

	All the strings are valid.

	In case of **list** currently the valid values are only non-negative
    integers and are set like `"1,2,34,56"` (quotes not required). The
    value is stored space-separated: `"1 2 34 56"`.

Accessing parameters
--------------------

The values can be accessed through the global array `ARGS[short]`. To
access a value by its long name use `${ARGS[${MAP_ARGS_LONG[long]}]}`.

The help can be accessed as `HELP_ARGS[short]`.

All bash variables are global by default, so the script must not use
the following names. They are public and used by argparse.sh. Internal
names start with `_argparse_` or `_ARGPARSE_`.

+ **ARGS**: associative array with the values, index *short* name. Ex: `${ARGS[e]}`

+ **MAP_LONG_ARGS**: Map from *short* to *long* names. Usually not needed by the user.

+ **MAP_ARGS_LONG**: Map from *long* to *short* names. Usually not needed by the user.

+ **HELP_ARGS**: Help string arrays. Index *short*.

+ **MANDATORY**: `true` if the argument is mandatory. Index *short*.

+ **ARG_TYPE**: Argument type. Index *short*.

+ **DEFAULTS**: Default values. Index *short*.

+ **ARGS_REST**: Indexed array with the remaining arguments. See below.

This is a WIP and of course can be improved, if you use/improve it
or you find any error/issue, please, contact me in order to improve,
correct or add you as a collaborator in this project.

A bool flag sets the opposite of its default; `--mybool=true|false`
sets the value explicitly.

An extra **REST** argument is automatically added when the input
contains arguments that are not options. These may appear before,
between or after the options; `--` ends option parsing and makes every
following argument a REST argument. This can be
accessed like: `ARGS[REST]`; it is a string, not an array, but it is
iterable or can be passed to other commands. Ex: `echo ${ARGS[REST]} |
wc -w` returns the number of elements (words) in the list.

Or:

```
for i in ${ARGS[REST]}; do
	echo $i
done
```

is also valid.

`ARGS[REST]` joins the arguments with spaces, so an argument that
contains spaces is split when iterated. To keep each argument intact,
use the indexed array `ARGS_REST`:

```
for i in "${ARGS_REST[@]}"; do
	echo "$i"
done
```

`${#ARGS_REST[@]}` returns the number of remaining arguments.

This is under GPLv3 license

**author:** Jimmy Aguilar Mena

**date:** 06/03/2018
