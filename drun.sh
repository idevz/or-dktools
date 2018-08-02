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

# KERNEL_URL=https://buildlogs.centos.org/c7.1708.00/kernel/20170822030048/3.10.0-693.el7.x86_64

set -ex
BASE_DIR=$(dirname $(cd $(dirname "$0") && pwd -P)/$(basename "$0"))
BUILDING_PATH=${BASE_DIR}/builds

# because of the GFW and the weak network
# using local package to install or not(currently signified to kernel packages)
DEFAULT_GFW=
GFW=${GFW=$DEFAULT_GFW}

# ./drun.sh build_stap
build_stap() {
	TARG_NAME=zhoujing/stap
	[ ! -z $1 ] && TARG_NAME=$1
	docker build \
		--build-arg \
		GFW=${GFW} \
		-t ${TARG_NAME} \
		-f ${BUILDING_PATH}/docker/stap.Dockerfile \
		${BUILDING_PATH}
	exit 0
}

start_fs() {
	sudo python -m SimpleHTTPServer 80
}

$@