#!/usr/bin/env bash

cat <<EOF

==================================================================

 This is a simple script to test the argparse bash script.
 You can call the script with the options specified using the long
 and short names.
 This is a WIP and of course can be improved, if you use/improve it
 or you find any error/issue, please, contact me in order to improve,
 correct or add you as a collaborator in this project.

 This is under GPLv3 license

 author: Jimmy Aguilar Mena
 email: kratsbinovish@gmail.com
 date: 06/03/2018

==================================================================

EOF

# This can be called for example: ./test_parser.sh -h -l 3 -o -p 1 --help

echo "Command: $0 $@"

source argparse.sh

add_argument -a h -l help -h "Funcion help" -t bool
add_argument -a t -l trueo -h "Funcion help" -t bool -d true
add_argument -a p -l print -h "Funcion print" -d 0
add_argument -a l -l loops -h "Number of loops" -d 10
add_argument -a o -l other


echo -e "\n Before"
printargs

parse_args "$@"
echo -e "\n After"

printargs

echo "Number of loops: "${ARGS[l]}
echo "Print value: "${LONG_ARGS[print]}
