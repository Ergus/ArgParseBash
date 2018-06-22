#!/usr/bin/env bash

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

cat <<EOF

==================================================================

 This is a simple script to test the argparse bash script.
 This one is specific for optional options
 This is a WIP and of course can be improved, if you use/improve it
 or you find any error/issue, please, contact me in order to improve,
 correct or add you as a collaborator in this project.

 This is under GPLv3 license

 author: Jimmy Aguilar Mena
 email: kratsbinovish@gmail.com
 date: 06/03/2018

==================================================================

EOF

# This can be called for example: ./test_mandatory.sh -m ttt -d bbb -b

echo "Command: $0 $@"

source argparse.sh

add_argument -a b -l bool -h "Boolean default false" -t bool
add_argument -a m -l mandatory -h "Mandatory argument"
add_argument -a d -l default -h "Default argument" -d "defvalue"

echo -e "\n Before (default)"
printargs

parse_args "$@"

echo -e "\n After (parsed)"
printargs
