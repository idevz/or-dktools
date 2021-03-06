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
GFW=${GFW}
OPEN=${OPEN}     # open motan or not
IGLB=${IGLB}     # internal_gitlab_token
OR_ENV=${OR_ENV} # debug, valgrind
OR_PREFIX=/usr/local/openresty
MOTAN_OPENRESTY_VERSION=${MOTAN_OPENRESTY_VERSION}
if [ ! -z ${OR_ENV} ]; then
	OR_PREFIX=${OR_PREFIX}-${OR_ENV}
fi
STAP=${STAP}
RESTY_J=${RESTY_J:-1}

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

# ./drun.sh build_or
# GFW=true RESTY_J=4 OR_ENV=debug ./drun.sh build_or
# GFW=true RESTY_J=4 ./drun.sh build_or
# GFW=true STAP=true RESTY_J=4 OR_ENV=debug ./drun.sh build_or zhoujing/openresty-stap
build_or() {
	TARG_NAME=zhoujing/openresty
	[ ! -z $1 ] && TARG_NAME=$1
	[ ! -z ${OR_ENV} ] && TARG_NAME=${TARG_NAME}:${OR_ENV}
	docker build \
		--build-arg GFW=${GFW} \
		--build-arg OR_ENV=${OR_ENV} \
		--build-arg OR_PREFIX=${OR_PREFIX} \
		--build-arg DOCKER=true \
		--build-arg STAP=${STAP} \
		--build-arg RESTY_J=${RESTY_J} \
		-t ${TARG_NAME} \
		-f ${BUILDING_PATH}/docker/or.Dockerfile \
		${BUILDING_PATH}
	exit 0
}

# OR_BASE_IMGE=zhoujing/openresty OR_ENV=debug ./drun.sh build_motan
# IGLB="PRIVATE-TOKEN: YOUR TOKEN" OPEN=not ./drun.sh build_motan
# IGLB="PRIVATE-TOKEN: YOUR TOKEN" OPEN=not OR_BASE_IMGE=zhoujing/openresty MOTAN_OPENRESTY_VERSION=0.0.1-rc.3 OR_ENV=debug ./drun.sh build_motan
build_motan() {
	TARG_NAME=zhoujing/or-motan
	[ "${OPEN}" == "not" ] && [ -z ${IGLB} ] && echo "must set a internal gitlab token for internal weito motan openresty installation." && exit 1
	[ "${OPEN}" == "not" ] && TARG_NAME=zhoujing/or-wmotan
	OR_BASE_IMGE=zhoujing/openresty
	[ ! -z $1 ] && TARG_NAME=$1
	[ ! -z ${OR_ENV} ] && TARG_NAME=${TARG_NAME}:${OR_ENV} &&
		OR_BASE_IMGE=${OR_BASE_IMGE}:${OR_ENV}
	docker build \
		--build-arg OPEN=${OPEN} \
		--build-arg IGLB="${IGLB}" \
		--build-arg OR_ENV=${OR_ENV} \
		--build-arg OR_PREFIX=${OR_PREFIX} \
		--build-arg OR_BASE_IMGE=${OR_BASE_IMGE} \
		--build-arg MOTAN_OPENRESTY_VERSION=${MOTAN_OPENRESTY_VERSION} \
		-t ${TARG_NAME} \
		-f ${BUILDING_PATH}/docker/or-motan.Dockerfile \
		${BUILDING_PATH}
	exit 0
}

start_fs() {
	sudo python -m SimpleHTTPServer 80
}

$@
