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

. argument-parsing.inc.sh

#
# uses a prefix and suffix of a file name to 
# find existing files and increments an index
# until a unique filename is found
#
function get-indexed-file-name() {
	local prefix
	local suffix
	parse-arguments "prefix:,suffix:" "$@"
	local index=0
	local filename="${prefix}${index}${suffix}"

	while [ -f "$filename" ] 
	do
		index=`expr $index + 1`
		filename="${prefix}${index}${suffix}"
	done

	echo "$filename"
}

