#!/usr/bin/env bash

### BEGIN ###
# Author: idevz
# Since: 2018/03/12
# Description:       Build and push WeiboMesh Docker image.
#	User input a build type, program will do the building things:
#	like:
# ./bp.sh bt                             building testing docker image
# ./bp.sh tti                            show image info  ./bp.sh tti
# GOLANG_VERSION=1.9 ./bp.sh bt         build both rpm and docker images with golang 1.9(default)"
### END ###

# ENV GFW
# ENV OR_ENV
# ENV STAP
# EVN DOCKER

set -ex
BASE_DIR=$(dirname $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))

[ ! -z ${DOCKER} ] &&
	cp ${BASE_DIR}/entrypoint.sh /entrypoint.sh &&
	chmod +x /entrypoint.sh

[ -x ${BASE_DIR}/common/base ] && . ${BASE_DIR}/common/base
[ -x ${BASE_DIR}/common/or-install ] && . ${BASE_DIR}/common/or-install

yum install --nogpgcheck -y libxml2-devel libxslt-devel gd-devel geoip-devel \
	gcc gcc-c++ automake autoconf libtool make zip unzip patch

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
	pkg_clean
}

build_or_env

if [ "${OR_ENV}" == "debug" ]; then
	export PATH=$PATH:${DEBUG_OR_PREFIX}/luajit/bin/:${DEBUG_OR_PREFIX}/nginx/sbin/:${DEBUG_OR_PREFIX}/bin/
	echo "export PATH=$PATH" >>/etc/profile
	[ ! -z ${DOCKER} ] &&
		ln -sf /dev/stdout ${DEBUG_OR_PREFIX}/nginx/logs/access.log &&
		ln -sf /dev/stderr ${DEBUG_OR_PREFIX}/nginx/logs/error.log
elif [ "${OR_ENV}" == "valgrind" ]; then
	export PATH=$PATH:${VAL_OR_PREFIX}/luajit/bin/:${VAL_OR_PREFIX}/nginx/sbin/:${VAL_OR_PREFIX}/bin/:${DEFAULT_LUAJIT_PREFIX}/bin/
	echo "export PATH=$PATH" >>/etc/profile
	[ ! -z ${DOCKER} ] &&
		ln -sf /dev/stdout ${VAL_OR_PREFIX}/nginx/logs/access.log &&
		ln -sf /dev/stderr ${VAL_OR_PREFIX}/nginx/logs/error.log
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

	cp ${BASE_DIR}/run/luajit_prove /usr/local/bin/luajit_prove &&
		chmod +x /usr/local/bin/luajit_prove
	cp ${BASE_DIR}/run/run /usr/local/bin/run &&
		chmod +x /usr/local/bin/run
fi
