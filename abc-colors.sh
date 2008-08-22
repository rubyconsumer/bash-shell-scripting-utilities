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

declare -a colors
colors=(BLACK RED GREEN YELLOW BLUE PURPLE CYAN GRAY )
i=0
for color in 30 31 32 33 34 35 36 37
do
	color_code="echo -en \\\033[${color}m"
	eval $(echo -n ${colors[${i}]}=\"
	echo ${color_code}\")
	# 4 is underline
	# 7 is inverse
	color_code="echo -en \\\033[1;${color}m"
	eval $(echo -n BRIGHT_${colors[${i}]}=\"
	echo ${color_code}\")
	i=`expr $i + 1`
done

RESET_COLOR="echo -en \\033[0;39m"
eval $(echo RESET_COLOR=\'$RESET_COLOR\')

