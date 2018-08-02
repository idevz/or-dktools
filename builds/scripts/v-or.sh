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
. /base.sh

kcopy builds/entrypoint.sh /entrypoint.sh +x

DEFAULT_CENTOS_VERSION=7
DEFAULT_RESTY_VERSION="1.13.6.2"
DEFAULT_RESTY_LUAROCKS_VERSION="2.4.3"
DEFAULT_RESTY_OPENSSL_VERSION="1.0.2k"
DEFAULT_RESTY_PCRE_VERSION="8.41"
DEFAULT_RESTY_ZLIB_VERSION="1.2.11"
DEFAULT_LUAJIT_VERSION="2.1.0-beta3"
DEFAULT_RESTY_J="1"

CENTOS_IMAGE=centos:${CV=$DEFAULT_CENTOS_VERSION}
RESTY_VERSION=${RESTY_VERSION=$DEFAULT_RESTY_VERSION}
RESTY_LUAROCKS_VERSION=${RESTY_LUAROCKS_VERSION=$DEFAULT_RESTY_LUAROCKS_VERSION}
RESTY_OPENSSL_VERSION=${RESTY_OPENSSL_VERSION=$DEFAULT_RESTY_OPENSSL_VERSION}
RESTY_PCRE_VERSION=${RESTY_PCRE_VERSION=$DEFAULT_RESTY_PCRE_VERSION}
RESTY_ZLIB_VERSION=${RESTY_ZLIB_VERSION=$DEFAULT_RESTY_ZLIB_VERSION}
RESTY_J=${RESTY_J=$DEFAULT_RESTY_J}
_RESTY_CONFIG_DEPS="--with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}"
RESTY_CONFIG_OPTIONS_MORE=""

yum-config-manager --add-repo http://mirrors.163.com/.help/CentOS7-Base-163.repo

# yum install -y gcc gcc-c++ automake autoconf libtool make
yum install --nogpgcheck -y libxml2-devel libxslt-devel gd-devel geoip-devel \
	gcc gcc-c++ automake autoconf libtool make zip unzip patch

# cd /tmp &&
# 	curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz &&
# 	tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz &&
# 	curl -fSL https://ftp.pcre.org/pub/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz &&
# 	tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz &&
# 	curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz &&
# 	tar xzf openresty-${RESTY_VERSION}.tar.gz &&
# 	curl -fSL https://github.com/luarocks/luarocks/archive/${RESTY_LUAROCKS_VERSION}.tar.gz -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz &&
# 	tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz

# RUN curl http://foo.com/package.tar.bz2 \
#     | tar -xjC /tmp/package \
#     && make -C /tmp/package

pkg_preparing() {
	cd /tmp &&
		kcopy "builds/pkgs/openssl-${RESTY_OPENSSL_VERSION}.tar.gz" openssl-${RESTY_OPENSSL_VERSION}.tar.gz &&
		kcopy "builds/pkgs/pcre-${RESTY_PCRE_VERSION}.tar.gz" pcre-${RESTY_PCRE_VERSION}.tar.gz &&
		kcopy "builds/pkgs/openresty-${RESTY_VERSION}.tar.gz" openresty-${RESTY_VERSION}.tar.gz &&
		kcopy "builds/pkgs/zlib-${RESTY_ZLIB_VERSION}.tar.gz" zlib-${RESTY_ZLIB_VERSION}.tar.gz &&
		kcopy "builds/pkgs/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz" luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz &&
		tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz &&
		tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz &&
		tar xzf openresty-${RESTY_VERSION}.tar.gz &&
		tar xzf zlib-${RESTY_ZLIB_VERSION}.tar.gz &&
		tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz
}

or_for_dev() {
	# export ASAN_OPTIONS=detect_leaks=0
	yum install -y valgrind-devel Python-devel gdb

	# CC="clang -fsanitize=address" ./configure --prefix=%{zlib_prefix}

	# make %{?_smp_mflags} CC="clang -fsanitize=address" \
	# 	CFLAGS='-O1 -fno-omit-frame-pointer -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g' \
	# 	SFLAGS='-O1 -fno-omit-frame-pointer -fPIC -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g' \
	# 	LDSHARED='clang -fsanitize=address -shared -Wl,-soname,libz.so.1,--version-script,zlib.map' \
	# 	>/dev/stderr

	# %install
	# make install

	# Compiler error reporting is too harsh for ./configure (perhaps remove -Werror).
	ZLIB_PREFIX=${DEBUG_OR_PREFIX}/zlib
	cd /tmp/zlib-${RESTY_ZLIB_VERSION} &&
		./configure --prefix=${ZLIB_PREFIX} &&
		make CFLAGS='-O3 -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g' \
			SFLAGS='-O3 -fPIC -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g' &&
		make install

	# ./config \
	# 	no-threads no-asm \
	# 	enable-ssl3 enable-ssl3-method \
	# 	shared zlib -g -O0 -DPURIFY \
	# 	--prefix=%{openssl_prefix} \
	# 	--libdir=lib \
	# 	-I%{zlib_prefix}/include \
	# 	-L%{zlib_prefix}/lib \
	# 	-Wl,-rpath,%{zlib_prefix}/lib:%{openssl_prefix}/lib

	# sed -i 's/ -O3 / -O0 /g' Makefile

	# make %{?_smp_mflags}

	# %install
	# make install_sw
	OPENSSL_PREFIX=${DEBUG_OR_PREFIX}/openssl
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

	# export CC="clang -fsanitize=address"
	# export CFLAGS="-O1 -fno-omit-frame-pointer -g"
	# export ASAN_OPTIONS=detect_leaks=0

	# ./configure \
	# 	--prefix=%{pcre_prefix} \
	# 	--disable-cpp \
	# 	--enable-jit \
	# 	--enable-utf \
	# 	--enable-unicode-properties

	# make %{?_smp_mflags} V=1 >/dev/stderr

	# %install
	# make install

	# configure: error: in `/tmp/pcre-8.41':
	# configure: error: C compiler cannot create executables
	# See `config.log' for more details
	PCRE_PREFIX=${DEBUG_OR_PREFIX}/pcre
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

	cd /tmp/openresty-${RESTY_VERSION} &&
		./configure \
			--prefix=${DEBUG_OR_PREFIX} \
			-j${RESTY_J} ${_RESTY_CONFIG_DEPS} \
			--with-debug \
			--with-no-pool-patch \
			--with-cc-opt="-I${ZLIB_PREFIX}/include -I${PCRE_PREFIX}/include -I${OPENSSL_PREFIX}/include -O0" \
			--with-ld-opt="-L${ZLIB_PREFIX}/lib -L${PCRE_PREFIX}/lib -L${OPENSSL_PREFIX}/lib -Wl,-rpath,${ZLIB_PREFIX}/lib:${PCRE_PREFIX}/lib:${OPENSSL_PREFIX}/lib" \
			--with-pcre-jit \
			--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT -DLUAJIT_USE_VALGRIND -DLUAJIT_USE_SYSMALLOC -O0' \
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
			--with-sha1-asm \
			--with-stream \
			--with-stream_ssl_module \
			--with-threads \
			${RESTY_CONFIG_OPTIONS_MORE} &&
		make -j${RESTY_J} &&
		make -j${RESTY_J} install
}

or_for_prd() {
	cd /tmp/openresty-${RESTY_VERSION} &&
		./configure \
			--prefix=${OR_PREFIX} \
			-j${RESTY_J} ${_RESTY_CONFIG_DEPS} \
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
}

OR_PREFIX=/usr/local/openresty
DEBUG_OR_PREFIX=/usr/local/openresty-debug
X_LUAJIT_PREFIX=/usr/local/luajit
install_or() {
	cd /tmp &&
		kcopy "builds/pkgs/LuaJIT-${DEFAULT_LUAJIT_VERSION}.tar.gz" LuaJIT-${DEFAULT_LUAJIT_VERSION}.tar.gz &&
		tar xzf LuaJIT-${DEFAULT_LUAJIT_VERSION}.tar.gz
	cd /tmp/LuaJIT-${DEFAULT_LUAJIT_VERSION} &&
		make PREFIX=${X_LUAJIT_PREFIX} &&
		make install PREFIX=${X_LUAJIT_PREFIX}
	if [ "${OR_ENV}" == "dev" ]; then
		or_for_dev
	else
		or_for_prd
	fi
}

install_luarocks() {
	cd /tmp/luarocks-${RESTY_LUAROCKS_VERSION} &&
		./configure \
			--prefix=${X_LUAJIT_PREFIX} \
			--with-lua=${X_LUAJIT_PREFIX} \
			--lua-suffix=jit-2.1.0-beta3 \
			--with-lua-include=${X_LUAJIT_PREFIX}/include/luajit-2.1 &&
		make build &&
		make install
}

pkg_clean() {
	if [ "${OR_ENV}" != "dev" ]; then
		cd /tmp &&
			rm -rf \
				openssl-${RESTY_OPENSSL_VERSION} \
				openresty-${RESTY_VERSION} \
				pcre-${RESTY_PCRE_VERSION}
	fi

	cd /tmp &&
		rm -rf \
			openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
			openresty-${RESTY_VERSION}.tar.gz \
			pcre-${RESTY_PCRE_VERSION}.tar.gz \
			luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
			luarocks-${RESTY_LUAROCKS_VERSION}
}

build_or_env() {
	pkg_preparing

	if [ "${OR_ENV}" == "dev" ]; then
		kcopy builds/centos7-stap.sh /tmp/centos7-stap.sh +x
		. /tmp/centos7-stap.sh
		install_systemtap
	fi

	install_or
	install_luarocks
	pkg_clean
}

build_or_env

if [ "${OR_ENV}" == "dev" ]; then
	echo "export PATH=$PATH:${DEBUG_OR_PREFIX}/luajit/bin/:${DEBUG_OR_PREFIX}/nginx/sbin/:${DEBUG_OR_PREFIX}/bin/:${X_LUAJIT_PREFIX}/bin/" >>/etc/profile &&
		. /etc/profile &&
		ln -sf /dev/stdout ${DEBUG_OR_PREFIX}/nginx/logs/access.log &&
		ln -sf /dev/stderr ${DEBUG_OR_PREFIX}/nginx/logs/error.log
else
	echo "export PATH=$PATH:${OR_PREFIX}/luajit/bin/:${OR_PREFIX}/nginx/sbin/:${OR_PREFIX}/bin/:${X_LUAJIT_PREFIX}/bin/" >>/etc/profile &&
		. /etc/profile &&
		ln -sf /dev/stdout ${OR_PREFIX}/nginx/logs/access.log &&
		ln -sf /dev/stderr ${OR_PREFIX}/nginx/logs/error.log
fi

if [ "${OR_ENV}" == "dev" ]; then
	luarocks install luacheck
	debuginfo-install --nogpgcheck -y glibc-2.17-222.el7.x86_64 libgcc-4.8.5-28.el7_5.1.x86_64
	kcopy builds/run/luajit_prove /usr/local/bin/luajit_prove +x
	kcopy builds/run/run /usr/local/bin/run +x
fi

yum autoremove -y

# sudo python -m SimpleHTTPServer 80
