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

 This is a script to test all the argparse test bash scripts.

 This is a WIP and of course can be improved, if you use/improve it
 or you find any error/issue, please, contact me in order to improve,
 correct or add you as a collaborator in this project.

 This is under GPLv3 license

 author: Jimmy Aguilar Mena
 email: kratsbinovish@gmail.com
 date: 03/05/2018

==================================================================

EOF

echo "================= Starting types =============================="

#  && exit 1 -> Intended to fail
#  || exit 1 -> Intended to success

./test_types.sh -p /tmpp && exit 1
./test_types.sh -p /tmp || exit 1

./test_types.sh -p /tmp -a /etc/caca && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3.14 && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f abc    && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 5      || exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 2.7171 || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -e option3 && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -e option2 || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 2.7171 -n || exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 2.7171 -n -t || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -w 00:70:00 && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -w 12:34:56 || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -l 6,7,89,0 || exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -l 8 || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -l 8 rest of arguments || exit 1

echo -e "\n================= Starting mandatory =======================\n"
read -p "Press [Enter] key to continue..."

./test_mandatory.sh -b  && exit 1
./test_mandatory.sh -d value && exit 1

./test_mandatory.sh -m value  || exit 1
./test_mandatory.sh -b -m value  || exit 1
./test_mandatory.sh -m value -d value  || exit 1

