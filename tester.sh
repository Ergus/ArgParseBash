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

# Source once; each corner case runs in a subshell, which gets a copy of the
# empty registry and discards its changes.
source ./argparse.sh

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

./test_types.sh -p /tmp -z            && exit 1
./test_types.sh -p /tmp --unknown     && exit 1

./test_types.sh -p /tmp -a /etc/caca && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3.14 && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f abc    && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 3a14   && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 5      || exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 5.     || exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 2.7171 || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -e option3 && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -e option2 || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 2.7171 -n || exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -f 2.7171 -n -t || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -w 00:70:00 && exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -w 12:34:56 || exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -w 34:56    || exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -w 99       && exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -l 6,7,89,0 || exit 1
./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -l 8 || exit 1

./test_types.sh -p /tmp -a /etc/bash.bashrc -i 3 -l 8 rest of arguments || exit 1

echo -e "\n================= Starting mandatory =======================\n"

./test_mandatory.sh -b  && exit 1
./test_mandatory.sh -d value && exit 1

./test_mandatory.sh -m value  || exit 1
./test_mandatory.sh -b -m value  || exit 1
./test_mandatory.sh -m value -d value  || exit 1


echo -e "\n================= Starting corner cases ====================\n"

# "| grep -q MSG || exit 1" -> Intended to print MSG (error cases where the message matters)
S() { add_argument -a s -l str -d x; }
I() { add_argument -a i -l intval -t int -d 1; }
M() { add_argument -a m -l mand; }
E() { add_argument -a e -t enum "$@"; }
B() { add_argument -a t -l tr -t bool -d true && add_argument -a n -l no -t bool; }

# Sourcing argparse.sh does not change the caller's shell options.
[[ $- != *e* ]] || exit 1

# add_argument, parse_args and printargs do not leak their working variables.
( S && parse_args -s y --str=z a && printargs >/dev/null && [[ ! -v o && ! -v opt && ! -v value && ! -v i && ! -v OPTARG ]] ) || exit 1

# Caller variables with common names do not affect the parser.
( S && E -e a,b -d a && opt_chars= && VALID_TYPES= && ENUMS=() && nargs=x && parse_args -s y -e b && [[ ${ARGS[s]} = y && ${ARGS[e]} = b ]] ) || exit 1

# Errors return 1 to the caller instead of exiting.
( add_argument                        ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -a s -d                ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -a s -x 1              ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -a s foo               ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -l foo                 ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -a ab                  ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -a s -l a=b            ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( S && add_argument -a s              ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( S && add_argument -a t -l str       ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -a s -t str            ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -a s -t enum           ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -a b -t bool -d yes    ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( add_argument -a i -t int -d x       ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( S && parse_args -z                  ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( S && parse_args --zz=1              ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( S && parse_args -s                  ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( S && parse_args --str               ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( I && parse_args -i x                ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( M && parse_args                     ; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1
( S && ARG_TYPE[s]= && parse_args -s y; echo "rc=$?" ) 2>/dev/null | grep -qx rc=1 || exit 1

# Values that look like echo options are kept.
( S && parse_args -s -n && [[ ${ARGS[s]} = -n ]] ) || exit 1
( S && parse_args --str=-e && [[ ${ARGS[s]} = -e ]] ) || exit 1
( add_argument -a s -d -E && [[ ${ARGS[s]} = -E ]] ) || exit 1

# Bool default honours true/false.
( add_argument -a b -t bool && [[ ${ARGS[b]} = false ]] ) || exit 1
( add_argument -a b -t bool -d true && [[ ${ARGS[b]} = true ]] )  || exit 1
( add_argument -a b -t bool -d false && [[ ${ARGS[b]} = false ]] ) || exit 1
( add_argument -a b -t bool -d yes ) && exit 1

# Long names match exactly.
( I && parse_args --intval=5 && [[ ${ARGS[i]} = 5 ]] ) || exit 1
( I && parse_args --int=5 )  2>&1 | grep -q 'Unknown option: --int' || exit 1
( I && parse_args --val=5 )  2>&1 | grep -q 'Unknown option: --val' || exit 1
( I && parse_args '--.*=5' ) 2>&1 | grep -qF 'Unknown option: --.*' || exit 1
( I && parse_args --=5 )     2>&1 | grep -q 'Unknown option: --$' || exit 1

# Types match exactly.
( add_argument -a s -t str -d a )         2>&1 | grep -q 'is not a valid type' || exit 1
( add_argument -a s -t "int float" -d 1 ) 2>&1 | grep -q 'is not a valid type' || exit 1
( add_argument -a s -t timer -d 00:01 && [[ ${ARG_TYPE[s]} = timer ]] ) || exit 1

# "empty" is an ordinary value; "" means unset.
( M && parse_args -m empty && [[ ${ARGS[m]} = empty ]] ) || exit 1
( M && parse_args --mand=empty && [[ ${ARGS[m]} = empty ]] ) || exit 1
( M && parse_args )              && exit 1
( M && parse_args -m '' )       2>&1 | grep -q 'is mandatory' || exit 1
( S && parse_args --str= && [[ -z ${ARGS[s]} ]] )      || exit 1
( I && parse_args --intval= )    && exit 1

# "--opt value".
( S && I && parse_args --intval 5 --str y && [[ ${ARGS[i]} = 5 && ${ARGS[s]} = y ]] ) || exit 1
( I && parse_args --intval -5 && [[ ${ARGS[i]} = -5 ]] )  || exit 1
( S && parse_args --str 'b c' && [[ ${ARGS[s]} = 'b c' ]] ) || exit 1
( S && parse_args --str '' && [[ -z ${ARGS[s]} ]] )    || exit 1
( S && parse_args --str )       && exit 1
( S && parse_args -s )          2>&1 | grep -q 'Option -s requires a value' || exit 1
( S && I && parse_args -i 2 -s ) 2>&1 | grep -q 'Option -s requires a value' || exit 1

# Enum values are literal.
( E -e a.c,b -d b && parse_args -e a.c && [[ ${ARGS[e]} = a.c ]] ) || exit 1
( E -e a.c,b -d b && parse_args -e abc )  && exit 1
( E -e 'x|y,z' -d z && parse_args -e x )    && exit 1
( E -e 'x|y,z' -d z && parse_args -e 'x|y' && [[ ${ARGS[e]} = 'x|y' ]] ) || exit 1
( E -e 'a*,b' -d b && parse_args -e aaa )  && exit 1
( E -e a,b,c -d a && parse_args -e a,b )  && exit 1
( E -e opt1,opt2 -d opt1 && parse_args -e opt ) && exit 1

# ARGS_REST keeps word boundaries.
( S && parse_args a 'b c' '' && [[ ${#ARGS_REST[@]} = 3 && ${ARGS_REST[1]} = 'b c' && -z ${ARGS_REST[2]} ]] ) || exit 1
( S && parse_args -s y && [[ ${#ARGS_REST[@]} = 0 && ! -v ARGS[REST] ]] ) || exit 1

# Options after positional arguments are parsed; "--" ends parsing.
( S && I && parse_args a -s y b --intval 3 c && [[ ${ARGS[s]} = y && ${ARGS[i]} = 3 && ${ARGS_REST[*]} = 'a b c' ]] ) || exit 1
( S && parse_args a -- -s z && [[ ${ARGS[s]} = x && ${ARGS_REST[*]} = 'a -s z' ]] ) || exit 1
( S && I && parse_args -s -- a -i 2 && [[ ${ARGS[s]} = -- && ${ARGS[i]} = 2 && ${ARGS_REST[*]} = a ]] ) || exit 1
( S && parse_args -s y -- && [[ ${ARGS[s]} = y && ${#ARGS_REST[@]} = 0 ]] ) || exit 1
( S && parse_args - -s y && [[ ${ARGS[s]} = y && ${ARGS_REST[*]} = - ]] )  || exit 1
( S && parse_args a -z )      && exit 1

# Duplicate names are rejected.
( S && add_argument -a s -t int -d 3 ) && exit 1
( S && add_argument -a t -l str -d y ) && exit 1
( S && add_argument -a t -l s -d y )   || exit 1

# Invalid add_argument options abort.
( add_argument -a s -x 1 -d y ) && exit 1
( add_argument -a s -d )        && exit 1
( add_argument -a s foo -d y )  2>&1 | grep -q 'add_argument: unexpected argument "foo"' || exit 1
( add_argument -a s -d y foo )  2>&1 | grep -q 'add_argument: unexpected argument "foo"' || exit 1

# Short names are one ASCII letter or digit.
( add_argument -a 7 -d y ) || exit 1
for name in ab : - '?' '*' . ' ' é; do
	( add_argument -a "$name" -d y ) && exit 1
done

# Long names are letters, digits, "_" or "-", not starting with "-".
( add_argument -a s -l my-long_2 -d x && parse_args --my-long_2=y && [[ ${ARGS[s]} = y ]] ) || exit 1
( add_argument -a s -l a=b    -d y ) 2>&1 | grep -q 'invalid long name' || exit 1
( add_argument -a s -l -x     -d y ) 2>&1 | grep -q 'invalid long name' || exit 1
( add_argument -a s -l 'a b'  -d y ) 2>&1 | grep -q 'invalid long name' || exit 1
( add_argument -a s -l ' '    -d y ) 2>&1 | grep -q 'invalid long name' || exit 1
( add_argument -a s -l é      -d y ) 2>&1 | grep -q 'invalid long name' || exit 1
( add_argument -a s -l '*'    -d y ) 2>&1 | grep -q 'invalid long name' || exit 1

# Bool flags set the opposite of the default; no toggling back.
( B && parse_args -t -t -n -n && [[ ${ARGS[t]} = false && ${ARGS[n]} = true ]] ) || exit 1
( B && parse_args -tt && [[ ${ARGS[t]} = false ]] ) || exit 1
( B && parse_args --tr --tr && [[ ${ARGS[t]} = false ]] ) || exit 1
( B && parse_args --no=true && [[ ${ARGS[n]} = true ]] )  || exit 1
( B && parse_args -n --no=false && [[ ${ARGS[n]} = false ]] ) || exit 1
( B && parse_args --no x && [[ ${ARGS[n]} = true && ${ARGS_REST[*]} = x ]] ) || exit 1
( B && parse_args --no=yes )   && exit 1

echo "All corner cases passed"
