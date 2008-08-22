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
. return-code-checking.sh

function obtain-service-lock() {
	local lock_file
	local contents
	parse-arguments "lock-file:,contents:" "$@"
	arg-not-empty --name lock-file --value "x$lock_file"

	[ -f "$lock_file" ]
	exit-if-zero --ret $? --message "Unable to obtain lock, file exists"
	
	if [ "x$contents" = "x" ]
	then
		touch $lock_file 
		exit-if-not-zero --ret $? --message "Unable to obtain lock, could not create $lock_file"
	else 
		(echo $contents > $lock_file) > /dev/null 2>&1
		exit-if-not-zero --ret $? --message "Unable to obtain lock, could not write $lock_file"
	fi

}

function remove-service-lock() {
	local lock_file
	local contents
	parse-arguments "lock-file:,contents:" "$@"
	arg-not-empty --name lock-file --value "x$lock_file"

	if [ ! -f "$lock_file" ]
	then
		echo-warn "$lock_file does not exist"
		return 1
	fi

	rm "$lock_file"
	exit-if-not-zero --ret $? --message "Lock file could not be removed"

}

function service-lock-exists() {
	local lock_file
	parse-arguments "lock-file:" "$@"
	arg-not-empty --name lock-file --value "x$lock_file"
	[ -f "$lock_file" ]
	exit-if-not-zero --ret $? --message "$lock_file does not exist"
}

function grep-for-message() {
	local log_file
	local match
	local timeout
	parse-arguments "log-file:,match:,timeout:" "$@"
	arg-not-empty --name log-file --value "x$log_file"
	arg-not-empty --name match --value "x$match"
	arg-not-empty --name timeout --value "x$timeout"
	local start_time=`date +%s`
	local now=`date +%s`
	local time_waited=`expr $now - $start_time`

	[ -f $log_file ]
	exit-if-not-zero --ret $? --message "$log_file does not exist"
	
	while [ "$time_waited" -lt "$timeout" ]
	do
		grep -q "$match" $log_file
		if [ "$?" = "0" ]
		then
			break
		fi

		echo-debug "sleeping 5"
		echo -n '.'
		sleep 5
		now=`date +%s`
		time_waited=`expr $now - $start_time`

	done

	if [ "$time_waited" -ge "$timeout" ]
	then
		return 1
	else
		return 0
	fi

}


