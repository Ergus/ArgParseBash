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
 This one is specific for types checking
 This is a WIP and of course can be improved, if you use/improve it
 or you find any error/issue, please, contact me in order to improve,
 correct or add you as a collaborator in this project.

 This is under GPLv3 license

 author: Jimmy Aguilar Mena
 email: kratsbinovish@gmail.com
 date: 03/05/2018

==================================================================

EOF

echo "Command: $0 $@"

source argparse.sh

add_argument -a s -l string -h "String parameter" -t string -d "mystring"
add_argument -a i -l int -h "int parameter" -t int -d 100
add_argument -a f -l float -h "float parameter" -t float -d 3.14

add_argument -a t -l true -h "True option" -t bool -d true
add_argument -a n -l notrue -h "Notrue option" -t bool

add_argument -a p -l path -h "Path option" -t path -d $HOME
add_argument -a a -l archive -h "Archive option" -t file -d /etc/fstab

add_argument -a e -l enum -h "Enum option" -t enum -e option1,option2 -d option1

add_argument -a w -l walltime -h "Time option" -t timer -d 00:00:10

add_argument -a l -l intlist -h "Number list" -t list -d 1,34,5,6


echo -e "\n Before"
printargs

parse_args "$@"
echo -e "\n After"

printargs

echo "Test list iteration"
for i in ${ARGS[l]}; do
	echo $i
done
