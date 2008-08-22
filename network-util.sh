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
. user-util.sh

case "`uname`" in
	
	Darwin*)
		function network-util-ifup() {
			ifconfig $1 $2 255.255.255.255 alias
			return $?
		}
		function network-util-ifdown() {
			ifconfig $1 $2 255.255.255.255 -alias
			return $?
		}
	;;
	Linux*)
		function network-util-ifup() {
			ifconfig $1 $2 
			return $?
		}
		function network-util-ifdown() {
			ifconfig $1 down
			return $?
		}
	;;
	SunOS*)
		function network-util-ifup() {
			ifconfig $1 plumb && \
			ifconfig $1 $2 up
			return $?
		}
		function network-util-ifdown() {
			ifconfig $1 down unplumb
		}
	;;
	*)
		echo-error "Unrecognized platform: `uname`"
		exit 1
	;;


esac

function bind-address() {
	local iface
	local ip
	require-root-user
	parse-arguments "iface:,ip:" "$@"
	arg-not-empty --name iface --value x$iface
	arg-not-empty --name ip --value x$ip
	echo-debug "bind-address"
	network-util-ip-is-loopback --ip $ip
	if [ "$?" = 0 ]
	then
		echo-debug "$ip is loopback"
		network-util-ip-is-bound-local --ip $ip
		exit-if-zero --ret $? --message "$ip is already bound locally"
		echo-debug "$ip is not bound locally"
	else
		network-util-ip-is-bound-local --ip $ip && network-util-ip-bound-remote --ip $ip 
		exit-if-not-zero --ret $? --message "$ip is already bound remotely"
	fi

	echo -n "Bringing up $ip on $iface"
	network-util-ifup $iface $ip
	echo-success-or-failure --ret $?
	return $?
}

function unbind-address() {
	local iface
	local ip
	require-root-user
	parse-arguments "iface:,ip:" "$@"
	arg-not-empty --name iface --value x$iface
	arg-not-empty --name ip --value x$ip
	network-util-ip-is-bound-local --ip $ip
	exit-if-not-zero --ret $? --message "$ip is not bound locally, cannot unbind"
	echo -n "Taking down $ip on $iface"
	network-util-ifdown $iface $ip
	echo-success-or-failure --ret $?
	return $?
}

function network-util-ip-is-loopback() {
	local ip
	parse-arguments "ip:" "$@"
	arg-not-empty --name ip --value x$ip
	echo-debug "checking if ip, $ip, is loopback"
	echo $ip | grep -q '^127.'
	return $?
}

function network-util-ip-is-bound-local() {
	local ip
	parse-arguments "ip:" "$@"
	arg-not-empty --name ip --value x$ip
	echo-debug "checking for local binding on $ip"
	ifconfig -a | grep -q $ip
	return $?
}

function network-util-ip-bound-remote() {
	local ip
	parse-arguments "ip:" "$@"
	arg-not-empty --name ip --value x$ip
	ping -c1 -q $ip > /dev/null 2>&1
	return $?
}


