#!/bin/sh

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

IMAGE_TAG=zhoujing/or-tools

DEFAULT_CENTOS_VERSION=7
DEFAULT_RESTY_VERSION="1.13.6.2"
DEFAULT_RESTY_LUAROCKS_VERSION="2.4.3"
DEFAULT_RESTY_OPENSSL_VERSION="1.0.2k"
DEFAULT_RESTY_PCRE_VERSION="8.41"
DEFAULT_RESTY_J="1"

CENTOS_IMAGE=centos:${CV=$DEFAULT_CENTOS_VERSION}
RESTY_VERSION=${RESTY_VERSION=$DEFAULT_RESTY_VERSION}
RESTY_LUAROCKS_VERSION=${RESTY_LUAROCKS_VERSION=$DEFAULT_RESTY_LUAROCKS_VERSION}
RESTY_OPENSSL_VERSION=${RESTY_OPENSSL_VERSION=$DEFAULT_RESTY_OPENSSL_VERSION}
RESTY_PCRE_VERSION=${RESTY_PCRE_VERSION=$DEFAULT_RESTY_PCRE_VERSION}
RESTY_J=${RESTY_J=$DEFAULT_RESTY_J}

RESTY_CONFIG_OPTIONS="\
        --with-file-aio \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_geoip_module=dynamic \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_image_filter_module=dynamic \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-http_xslt_module=dynamic \
        --with-ipv6 \
        --with-mail \
        --with-mail_ssl_module \
        --with-md5-asm \
        --with-pcre-jit \
        --with-sha1-asm \
        --with-stream \
        --with-stream_ssl_module \
        --with-threads \
        "

DEBUG_RESTY_CONFIG_OPTIONS="\
        --with-debug \
        --with-no-pool-patch \
        --with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_USE_VALGRIND -DLUAJIT_USE_SYSMALLOC -O0' \
        --with-dtrace-probes \
        --with-poll_module \
        --with-file-aio \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_geoip_module=dynamic \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_image_filter_module=dynamic \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-http_xslt_module=dynamic \
        --with-ipv6 \
        --with-mail \
        --with-mail_ssl_module \
        --with-md5-asm \
        --with-pcre-jit \
        --with-sha1-asm \
        --with-stream \
        --with-stream_ssl_module \
        --with-threads \
        "

NOTIC_PREFIX="\n - --- --- "
NOTIC_SUFFIX=" --- --- -\n "

xnotic() {
	echo ${NOTIC_PREFIX}$1${NOTIC_SUFFIX}
}

source_to_test_image() {
	# && curl -fSL -o linux-\${KERNELVER}.tar.gz https://www.kernel.org/pub/linux/kernel/v4.x/linux-\${KERNELVER}.tar.gz
	cat >${BASE_DIR}/Dockerfile <<EOF
FROM $CENTOS_IMAGE

# ---------------- #
#     Building     #
# ---------------- #

LABEL maintainer="idevz <zhoujing00k@gmail.com>"

# Docker Build Arguments
ARG RESTY_VERSION=$RESTY_VERSION
ARG RESTY_LUAROCKS_VERSION=$RESTY_LUAROCKS_VERSION
ARG RESTY_OPENSSL_VERSION=$RESTY_OPENSSL_VERSION
ARG RESTY_PCRE_VERSION=$RESTY_PCRE_VERSION
ARG RESTY_J=$RESTY_J
ARG RESTY_CONFIG_OPTIONS="$RESTY_CONFIG_OPTIONS"
ARG DEBUG_RESTY_CONFIG_OPTIONS="$DEBUG_RESTY_CONFIG_OPTIONS"
ARG RESTY_CONFIG_OPTIONS_MORE=""

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}"

# 1) Install apt dependencies
# 2) Download and untar OpenSSL, PCRE, and OpenResty
# 3) Build OpenResty
# 4) Cleanup

RUN yum-config-manager --add-repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
        && yum install --nogpgcheck -y curl \
        zlib-devel \
        libxml2-devel \
        libxslt-devel \
        gd-devel \
        geoip-devel \
        perl-devel \
        gcc gcc-c++ automake autoconf libtool make zip unzip valgrind valgrind-devel systemtap-sdt-devel

RUN cd /tmp \
        && curl -fSL https://www.openssl.org/source/openssl-\${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-\${RESTY_OPENSSL_VERSION}.tar.gz \
        && tar xzf openssl-\${RESTY_OPENSSL_VERSION}.tar.gz \
        && curl -fSL https://ftp.pcre.org/pub/pcre/pcre-\${RESTY_PCRE_VERSION}.tar.gz -o pcre-\${RESTY_PCRE_VERSION}.tar.gz \
        && tar xzf pcre-\${RESTY_PCRE_VERSION}.tar.gz \
        && curl -fSL https://openresty.org/download/openresty-\${RESTY_VERSION}.tar.gz -o openresty-\${RESTY_VERSION}.tar.gz \
        && tar xzf openresty-\${RESTY_VERSION}.tar.gz \
        && curl -fSL https://github.com/luarocks/luarocks/archive/\${RESTY_LUAROCKS_VERSION}.tar.gz -o luarocks-\${RESTY_LUAROCKS_VERSION}.tar.gz \
        && tar xzf luarocks-\${RESTY_LUAROCKS_VERSION}.tar.gz

RUN yum install -y patch

RUN cd /tmp \
        && cd /tmp/openresty-\${RESTY_VERSION} \
        && ./configure -j\${RESTY_J} \${_RESTY_CONFIG_DEPS} \
        --with-debug \
        --with-no-pool-patch \
        --with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_USE_VALGRIND -DLUAJIT_USE_SYSMALLOC -O0' \
        --with-dtrace-probes \
        --with-poll_module \
        --with-file-aio \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_geoip_module=dynamic \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_image_filter_module=dynamic \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-http_xslt_module=dynamic \
        --with-ipv6 \
        --with-mail \
        --with-mail_ssl_module \
        --with-md5-asm \
        --with-pcre-jit \
        --with-sha1-asm \
        --with-stream \
        --with-stream_ssl_module \
        --with-threads \
        \${RESTY_CONFIG_OPTIONS_MORE} \
        && make -j\${RESTY_J} \
        && make -j\${RESTY_J} install \
        && cd /tmp \
        && rm -rf \
        openssl-\${RESTY_OPENSSL_VERSION} \
        openssl-\${RESTY_OPENSSL_VERSION}.tar.gz \
        openresty-\${RESTY_VERSION}.tar.gz openresty-\${RESTY_VERSION} \
        pcre-\${RESTY_PCRE_VERSION}.tar.gz pcre-\${RESTY_PCRE_VERSION} \
        && cd luarocks-\${RESTY_LUAROCKS_VERSION} \
        && ./configure \
        --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --lua-suffix=jit-2.1.0-beta3 \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
        && make build \
        && make install \
        && cd /tmp \
        && rm -rf luarocks-\${RESTY_LUAROCKS_VERSION} \
        luarocks-\${RESTY_LUAROCKS_VERSION}.tar.gz \
        linux-\${KERNELVER}.tar.gz \
        && yum autoremove -y \
        && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
        && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

# Add additional binaries into PATH for convenience
ENV PATH=\$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/

# TODO: remove any other apt packages?
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
EOF

	docker build -t ${IMAGE_TAG} .
	xnotic "testing docker images build done."
	# docker push ${IMAGE_TAG}
	xnotic "docker push to registry.api.weibo.com done."
	# rm ${BASE_DIR}/Dockerfile
}

build_test_image() {
	source_to_test_image
}

show_test_images_info() {
	docker inspect --format='{{json .Config}}' registry.api.weibo.com/openapi_rd/weibo-mesh:test | jq .Env
}

if [ $# == 0 ]; then
	echo "\nNeed to point which type you want to build ?

        like:
        GOLANG_VERSION=1.9 ./bp.sh bt

        examples:
        ./bp.sh bt                             building testing docker image
            ./bp.sh bt [\$TEST_MOTAN_GO_TAG \$TEST_WEIBO_MOTAN_GO_TAG \$WEIBO_MESH_VERSION \$TAG_MESSAGE \$TAG_DESCRIPTION]

        ./bp.sh tti                            show test image info
            ./bp.sh tti"
else
	if [ $1 == "bt" ]; then
		build_test_image $2 $3 $4 $5 $6
	elif [ $1 == "tti" ]; then
		show_test_images_info
	fi
fi
