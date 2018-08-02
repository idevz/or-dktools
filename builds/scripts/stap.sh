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

set -ex

BASE_DIR=$(dirname $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))

[ -x ${BASE_DIR}/common/base ] && . ${BASE_DIR}/common/base
[ -x ${BASE_DIR}/common/centos7-stap ] && . ${BASE_DIR}/common/centos7-stap

if [ -z ${GFW} ]; then
	install_systemtap
else
	local_install_systemtap
fi
