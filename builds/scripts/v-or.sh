#!/usr/bin/env bash

### BEGIN ###
# Author: idevz
# Since: 2018/03/12
# Description:       Build openresty for many env like debug, production, valgrind.
#	User input a args through env params:
#	like:
#   OR_PREFIX=/usr/local/openresty RESTY_J=4 ./v-or.sh
#   OR_PREFIX=/usr/local/openresty-debug OR_ENV=debug RESTY_J=4 ./v-or.sh
#   OR_PREFIX=/usr/local/openresty-valgrind OR_ENV=valgrind RESTY_J=4 ./v-or.sh
### END ###

# ENV GFW
# ENV OR_ENV
# ENV STAP
# EVN DOCKER

set -ex
BASE_DIR=$(dirname $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
DEFAULT_LUAJIT_PREFIX=/usr/local/luajit

[ ! -z ${DOCKER} ] &&
	cp ${BASE_DIR}/entrypoint.sh /entrypoint.sh &&
	chmod +x /entrypoint.sh

OR_PREFIX=${OR_PREFIX:-"/usr/local/openresty"}

[ -x ${BASE_DIR}/common/base ] && . ${BASE_DIR}/common/base
[ -x ${BASE_DIR}/common/or-install ] && . ${BASE_DIR}/common/or-install

yum install --nogpgcheck -y libxslt-devel gd-devel geoip-devel \
	gcc gcc-c++ make unzip patch \
	perl perl-ExtUtils-Embed \
	which less strace

install_or() {
	if [ "${OR_ENV}" == "debug" ]; then
		or_for_debug
	elif [ "${OR_ENV}" == "valgrind" ]; then
		or_for_valgrind
	else
		or_for_prd
	fi
}

build_or_env() {
	if [ -z ${GFW} ]; then
		pkg_preparing
	else
		local_pkg_preparing
	fi

	if [ ! -z ${STAP} ] && [ "${OR_ENV}" == "debug" ] || [ "${OR_ENV}" == "valgrind" ]; then
		[ -x ${BASE_DIR}/common/centos7-stap ] && . ${BASE_DIR}/common/centos7-stap
		if [ -z ${GFW} ]; then
			install_systemtap
		else
			local_install_systemtap
		fi
	fi

	install_or
	install_luarocks
	install_test_nginx
	pkg_clean
}

build_or_env

if [ "${OR_ENV}" == "valgrind" ]; then
	export PATH=$PATH:${OR_PREFIX}/luajit/bin/:${OR_PREFIX}/nginx/sbin/:${OR_PREFIX}/bin/:${DEFAULT_LUAJIT_PREFIX}/bin/
	echo "export PATH=$PATH" >>/etc/profile
	[ ! -z ${DOCKER} ] &&
		ln -sf /dev/stdout ${OR_PREFIX}/nginx/logs/access.log &&
		ln -sf /dev/stderr ${OR_PREFIX}/nginx/logs/error.log
else
	export PATH=$PATH:${OR_PREFIX}/luajit/bin/:${OR_PREFIX}/nginx/sbin/:${OR_PREFIX}/bin/
	echo "export PATH=$PATH" >>/etc/profile
	[ ! -z ${DOCKER} ] &&
		ln -sf /dev/stdout ${OR_PREFIX}/nginx/logs/access.log &&
		ln -sf /dev/stderr ${OR_PREFIX}/nginx/logs/error.log
fi

if [ "${OR_ENV}" == "debug" ] || [ "${OR_ENV}" == "valgrind" ]; then
	luarocks install luacheck
	yum install -y gdb Python-devel
	debuginfo-install --nogpgcheck -y glibc libgcc

	for X_FILE in $(ls ${BASE_DIR}/run); do
		cp ${BASE_DIR}/run/${X_FILE} /usr/local/bin/${X_FILE} &&
			chmod +x /usr/local/bin/${X_FILE}
	done
fi
