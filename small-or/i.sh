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

yum-config-manager --add-repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
yum-config-manager --enable CentOS7-Base-163\*

yum install --nogpgcheck -y zlib-devel libxml2* libxslt* gd-devel geoip-devel \
	gcc gcc-c++ make unzip patch \
	perl perl-ExtUtils-Embed

# gcc gcc-c++ automake autoconf libtool make zip unzip

RESTY_VERSION="1.13.6.2"
RESTY_LUAROCKS_VERSION="2.4.3"
RESTY_OPENSSL_VERSION="1.0.2k"
RESTY_PCRE_VERSION="8.41"
RESTY_J="4"
RESTY_CONFIG_OPTIONS_MORE=""

_RESTY_CONFIG_DEPS="--with-openssl=$(pwd)/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=$(pwd)/pcre-${RESTY_PCRE_VERSION}"

cd /tmp &&
	tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz &&
	tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz &&
	tar xzf zlib-1.2.11.tar.gz &&
	tar xzf openresty-${RESTY_VERSION}.tar.gz &&
	cd /tmp/openresty-${RESTY_VERSION} &&
	./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} \
		--with-ld-opt="-Wl,-rpath='\\\'\\\$\\\$ORIGIN/lib\\\''" \
		--with-zlib=/tmp/zlib-1.2.11 \
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
		${RESTY_CONFIG_OPTIONS_MORE} &&
	make -j${RESTY_J} &&
	make -j${RESTY_J} install

export PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/
echo "export PATH=$PATH" >>/etc/profile

mkdir -p /usr/local/openresty/nginx/sbin/lib
for DEP_F in $(ldd /usr/local/openresty/nginx/sbin/nginx | grep -Eo '(\/.*) |(/lib64/.*)'); do
	cp ${DEP_F} /usr/local/openresty/nginx/sbin/lib/${DEP_F}
done
