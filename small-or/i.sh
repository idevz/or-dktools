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

yum install --nogpgcheck -y gcc gcc-c++ make unzip patch perl perl-ExtUtils-Embed gd-devel geoip-devel strace
# zlib-devel libxslt-devel \
# python-devel

# gcc gcc-c++ automake autoconf libtool make zip unzip
RESTY_VERSION=${RESTY_VERSION:-"1.13.6.2"}
RESTY_LUAROCKS_VERSION=${RESTY_LUAROCKS_VERSION:-"2.4.3"}
RESTY_OPENSSL_VERSION=${RESTY_OPENSSL_VERSION:-"1.0.2k"}
RESTY_PCRE_VERSION=${RESTY_PCRE_VERSION:-"8.41"}
RESTY_ZLIB_VERSION=${RESTY_ZLIB_VERSION:-"1.2.11"}
RESTY_LIBXML_VERSION=${RESTY_LIBXML_VERSION:-"2.9.8"}
RESTY_XSLT_VERSION=${RESTY_XSLT_VERSION:-"1.1.32"}
RESTY_J=${RESTY_J:-"1"}

RESTY_J="4"
RESTY_CONFIG_OPTIONS_MORE=""

_RESTY_CONFIG_DEPS="--with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}"

dev_preparing() {
	cd /tmp &&
		tar xzf libxslt-${RESTY_XSLT_VERSION}.tar.gz &&
		tar xzf libxml2-${RESTY_LIBXML_VERSION}.tar.gz &&
		tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz &&
		tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz &&
		tar xzf zlib-${RESTY_ZLIB_VERSION}.tar.gz &&
		tar xzf openresty-${RESTY_VERSION}.tar.gz

	cd /tmp/libxml2-${RESTY_LIBXML_VERSION} &&
		./configure --prefix=/usr --disable-static --with-history --with-python=/usr/bin/python3 &&
		make && make install

	cd /tmp/libxslt-${RESTY_XSLT_VERSION} &&
		sed -i s/3000/5000/ libxslt/transform.c doc/xsltproc.{1,xml} && ./configure --prefix=/usr --disable-static &&
		make && make install

	ZLIB_PREFIX=/usr
	cd /tmp/zlib-${RESTY_ZLIB_VERSION} &&
		./configure --prefix=${ZLIB_PREFIX} &&
		make CFLAGS='-O3 -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g' \
			SFLAGS='-O3 -fPIC -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g' &&
		make install

	OPENSSL_PREFIX=/usr
	cd /tmp/openssl-${RESTY_OPENSSL_VERSION} &&
		./config \
			no-threads no-asm \
			enable-ssl3 enable-ssl3-method \
			shared zlib -g -O0 -DPURIFY \
			--prefix=${OPENSSL_PREFIX} \
			--libdir=lib \
			-I${ZLIB_PREFIX}/include \
			-L${ZLIB_PREFIX}/lib \
			-Wl,-rpath,${ZLIB_PREFIX}/lib:${OPENSSL_PREFIX}/lib &&
		sed -i 's/ -O3 / -O0 /g' Makefile &&
		make &&
		make install_sw

	PCRE_PREFIX=/usr
	cd /tmp/pcre-${RESTY_PCRE_VERSION} &&
		./configure \
			--prefix=${PCRE_PREFIX} \
			--includedir=${PCRE_PREFIX}/include \
			--disable-cpp \
			--enable-jit \
			--enable-utf \
			--enable-unicode-properties &&
		make V=1 &&
		make install
}

# dev_preparing

cd /tmp &&
	tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz &&
	tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz &&
	tar xzf zlib-${RESTY_ZLIB_VERSION}.tar.gz &&
	tar xzf openresty-${RESTY_VERSION}.tar.gz

# tar xzf libxslt-${RESTY_XSLT_VERSION}.tar.gz &&
# tar xzf libxml2-${RESTY_LIBXML_VERSION}.tar.gz &&
# cd /tmp/libxml2-${RESTY_LIBXML_VERSION} &&
# 	./configure --prefix=/usr --disable-static --with-history --with-python=/usr/bin/python3 &&
# 	make && make install

# cd /tmp/libxslt-${RESTY_XSLT_VERSION} &&
# 	sed -i s/3000/5000/ libxslt/transform.c doc/xsltproc.{1,xml} && ./configure --prefix=/usr --disable-static &&
# 	make && make install

# --with-zlib=/tmp/zlib-1.2.11 \
# --with-file-aio \
# --with-http_addition_module \
# --with-http_auth_request_module \
# --with-http_dav_module \
# --with-http_flv_module \
# --with-http_geoip_module=dynamic \
# --with-http_gunzip_module \
# --with-http_gzip_static_module \
# --with-http_image_filter_module=dynamic \
# --with-http_mp4_module \
# --with-http_random_index_module \
# --with-http_realip_module \
# --with-http_secure_link_module \
# --with-http_slice_module \
# --with-http_ssl_module \
# --with-http_stub_status_module \
# --with-http_sub_module \
# --with-http_v2_module \
# --with-ipv6 \
# --with-mail \
# --with-mail_ssl_module \
# --with-md5-asm \
# --with-pcre-jit \
# --with-sha1-asm \
# --with-stream \
# --with-stream_ssl_module \
# --with-threads \

# --with-ld-opt="\"-Wl,-rpath='\\\'\\\$\\\$ORIGIN/lib\\\''\"" \
# --with-ld-opt="-Wl,-rpath=\\$\$ORIGIN/lib\\"

# '--with-ld-opt="-Wl,-rpath='\\'\\\$\\\$ORIGIN/lib\\''"' \
# --with-ld-opt='"-Wl,-rpath=\\\\$\\\$ORIGIN/lib\\"'

# --with-ld-opt='"-Wl,-rpath='\\'\\\$\\\$ORIGIN/lib\\''"'
# --with-ld-opt="-Wl,-rpath=\\\\$\\\$ORIGIN/lib\\"

# --with-ld-opt='-Wl,-rpath,/usr/local/openresty/luajit/lib -Wl,-rpath='\'\$\$ORIGIN/lib\'''
cd /tmp/openresty-${RESTY_VERSION} &&
	./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} \
		--with-zlib=/tmp/zlib-1.2.11 \
		--with-openssl=/tmp/openssl-1.0.2k --with-pcre=/tmp/pcre-8.41 \
		--with-ld-opt=-Wl,-rpath="'""\\'"'\$\$ORIGIN/lib'"\\'""'" \
		--user=root --group=root \
		${RESTY_CONFIG_OPTIONS_MORE} &&
	make -j${RESTY_J} &&
	make -j${RESTY_J} install

export PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/
echo "export PATH=$PATH" >>/etc/profile

mkdir -p /usr/local/openresty/nginx/sbin/lib
for DEP_F in $(ldd /usr/local/openresty/nginx/sbin/nginx | grep -Eo '(\/.*) |(/lib64/.*) '); do
	cp ${DEP_F} /usr/local/openresty/nginx/sbin/lib/$(basename ${DEP_F})
done

# ./configure --prefix=/usr/local/openresty --with-ld-opt="-Wl,-rpath='\\'\\\$\\\$ORIGIN/lib\\''" \
# --with-openssl=/tmp/openssl-1.0.2k \
# --with-pcre=/tmp/pcre-8.41 \
# --with-file-aio \
# --with-http_addition_module \
# --with-http_auth_request_module \
# --with-http_dav_module \
# --with-http_flv_module \
# --with-http_geoip_module=dynamic \
# --with-http_gunzip_module \
# --with-http_gzip_static_module \
# --with-http_image_filter_module=dynamic \
# --with-http_mp4_module \
# --with-http_random_index_module \
# --with-http_realip_module \
# --with-http_secure_link_module \
# --with-http_slice_module \
# --with-http_ssl_module \
# --with-http_stub_status_module \
# --with-http_sub_module \
# --with-http_v2_module \
# --with-ipv6 \
# --with-mail \
# --with-mail_ssl_module \
# --with-md5-asm \
# --with-pcre-jit \
# --with-sha1-asm \
# --with-stream \
# --with-stream_ssl_module \
# --with-threads \
# --with-http_xslt_module=dynamic \
# -j4

#     1  llr zxf libxml2-2.9.8.tar.gz
#     2  curl -fSL http://xmlsoft.org/sources/libxslt-1.1.32.tar.gz -o libxslt-1.1.32.tar.gz
#     3  tar zxf libxslt-1.1.32.tar.gz
#     4  cd libxslt-1.1.32libxml2-2.9.8-python3_hack-1.patch
#     5  llconfigure --prefix=/usr                --disable-static             --with-history               --with-python=/usr/bin/python3 && make
#     6  sed -i s/3000/5000/ libxslt/transform.c doc/xsltproc.{1,xml} && ./configure --prefix=/usr --disable-static                   && make
#     7  yum install -y gccix=/usr                --disable-static             --with-history               --with-python=/usr/bin/python3 && make
#     8  sed -i s/3000/5000/ libxslt/transform.c doc/xsltproc.{1,xml} && ./configure --prefix=/usr --disable-static                   && make
#     9  yum install -y libxml2el -y
#    10  sed -i s/3000/5000/ libxslt/transform.c doc/xsltproc.{1,xml} && ./configure --prefix=/usr --disable-static                   && make
#    11  ..r/bin/python3 && make
#    12  cd ..install
#    13  curl -fSL http://xmlsoft.org/sources/libxml2-2.9.8.tar.gz -o libxml2-2.9.8.tar.gz
#    14  tar zxf libxml2-2.9.8.tar.gz ransform.c doc/xsltproc.{1,xml} && ./configure --prefix=/usr --disable-static                   && make
#    15  cd libxml2-2.9.8
#    16  yum install -y patch
#    17  patch -Np1 -i ../libxml2-2.9.8-python3_hack-1.patchlt-1.1.3
#    18  ./configure --prefix=/usr                --disable-static             --with-history               --with-python=/usr/bin/python3 && make
#    19  yum install -y make
#    20  ./configure --prefix=/usr                --disable-static             --with-history               --with-python=/usr/bin/python3 && make
#    21  yum list python
#    22  yum install python-devel -y
#    23  ./configure --prefix=/usr                --disable-static             --with-history               --with-python=/usr/bin/python3 && make
#    24  make install
#    25  cd ../libxslt-1.1.32
#    26  sed -i s/3000/5000/ libxslt/transform.c doc/xsltproc.{1,xml} && ./configure --prefix=/usr --disable-static                   && make
#    27  make install
#    28  history
#    29  history
