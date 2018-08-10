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

[ -x ${BASE_DIR}/common/base ] && . ${BASE_DIR}/common/base
[ -x ${BASE_DIR}/common/motan-openresty ] && . ${BASE_DIR}/common/motan-openresty

if [ "${OPEN}" == "not" ]; then
	install_weibo_motan_openresty
	install_v
else
	install_motan_openresty
fi
