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

. return-code-checking.sh
. argument-parsing.inc.sh

function require-root-user() {
	exit-if-not-zero --ret $UID --message "root permissions required"
}

function forbid-root-user() {
	local message
	parse-arguments "message:" "$@"
	if [ "x$message" = "x" ]
	then
		message="do not run this as root"
	fi

	[ "$UID" != 0 ]
	exit-if-not-zero --ret $? --message "$message"
}
