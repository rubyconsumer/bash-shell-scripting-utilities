#!/bin/bash
#  Copyright 2008 Archie Cowan
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#         http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.

. abc-logging.sh

if [ "$0" != "-bash" ]
then
	export script=`basename $0`
else 
	export script="$USER-shell"
fi



function arg-not-empty() {
	local name
	local value
	local message
	parse-arguments "name:,value:,message:" "$@"
	if [ "x$name" = "x" ]
	then
		echo-error Argument, name, is required
		exit 1
	fi
	if [ "x$value" = "x" ]
	then
		echo-error Argument, value, is required
		exit 1
	fi

	value="`eval echo $value`"

	if [ "$value" = "x" ]
	then
		if [ "x$message" != "x" ]
		then
			echo-error -n "$name "
			echo "$message"
		else
			echo-error "$name must be specified"
		fi
		echo-warn $usage
		exit 1
	fi
}

parse-arguments() {
	local args
	args=$1
	shift


	# this doesn't work in solaris 
	## or anywhere/??
	#if [ "SunOS" != "`uname -s`" ] ; then
	#	ARGS=`getopt -o hX -l help,$args -n "$script" -- "$@"`
	#	if [ "$?" != 0 ] 
	#	then 
	#		echo "$script: Error parsing arguments" >&2 
	#		exit 1
	#	fi

	#	if [ "x$usage" = "x" ]
	#	then
	#		echo-error USAGE IS NOT SET
	#		exit 1
	#	fi
	#	eval set -- "$@"
	#else
	eval set -- "$@ --"
	#fi

	while true ; do
		case "$1" in
			-h|--help)
				echo-success $usage
				exit 0
				shift
			;;
			-X)
				echo-warn Enabling DEBUG
				export DEBUG=1
				shift
			;;
			--[a-zA-Z0-9]*)
				arg=`echo $1 | sed -e 's/^--//' -e 's/-/_/'`
				var=`echo $1 | sed -e 's/^--//' -e 's/-/_/'`

				echo-debug "args is $args"
				echo-debug "checking if variable, ${arg}, needs input or boolean... "
				echo $args | tr ',' '\n' | grep -q "^${arg}:$"
				if [ "$?" = 0 ]
				then
					echo-debug "input"
					eval "$var=\"$2\""
					echo-debug "argument $var = $2"
					shift 2
				else
					echo-debug "boolean"
					eval "$var=yes"
					echo-debug "argument $var = yes"
					shift 
				fi
			;;
			--) 
				shift
				break
				
			;;
			*) 
				echo "$script: Error setting arguments"
				exit 1
			;;
		esac
	done
		
}
