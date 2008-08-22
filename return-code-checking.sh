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
. argument-parsing.inc.sh

function exit-if-zero() {
	local ret
	local message
	parse-arguments "ret:,message:" "$@"
	arg-not-empty --name ret --value x$ret
	arg-not-empty --name message --value "x$message"
	[ "$ret" != "0" ]
	exit-if-not-zero --ret $? --message "$message"
}

function exit-if-not-zero () {
	local ret
	local message
	parse-arguments "ret:,message:" "$@"
	arg-not-empty --name ret --value x$ret
	arg-not-empty --name message --value "x$message"

	if [ "$ret" != 0 ]
	then
		echo-error $message
		exit $ret
	fi
}

function echo-success-or-failure() {
	local ret
	local other_ret
	local other_message
	local other_color
	(
	parse-arguments "ret:,other-ret:,other-message:,other-color:" "$@"
	arg-not-empty --name ret --value x$ret
	echo -en "\\033[60G"
	$BLUE && echo -n '[ ' && $RESET_COLOR
	if [ "x$other_ret" != "x" -a "x$other_message" != "x" -a "$ret" = "$other_ret" ]
	then
		eval "\$$other_color"
		echo -n $other_message
	elif [ "$ret" = "0" ]
	then
		$GREEN
		echo -n ok
	else
		$RED
		echo -n '!!'
	fi
	$RESET_COLOR
	$BLUE && echo ' ]' && $RESET_COLOR
	return $ret
	)
	return $?
}

