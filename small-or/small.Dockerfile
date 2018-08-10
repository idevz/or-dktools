FROM zhoujing/small-or-base

FROM busybox

COPY --from=0 /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=0 /lib64/libc.so.6 /lib64/libc.so.6
COPY --from=0 /lib64/libdl.so.2 /lib64/libdl.so.2
COPY --from=0 /lib64/libtinfo.so.5 /lib64/libtinfo.so.5
COPY --from=0 /bin/bash /bin/bash
COPY --from=0 /usr/bin/echo /usr/bin/echo

COPY --from=0 /lib64/libgcc_s.so.1 /lib64/libgcc_s.so.1
COPY --from=0 /usr/bin/strace /usr/bin/strace

# COPY --from=0 /etc/profile /etc/profile
COPY --from=0 /usr/local/openresty /usr/local/openresty
COPY --from=0 /lib64/libnss_files.so.2 /lib64/libnss_files.so.2

# COPY --from=0 /entrypoint.sh /entrypoint.sh
# RUN groupadd -r idevz && useradd -r -g idevz idevz

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

# 4 apk add --update binutils
# 5 readelf
# 6 readelf /usr/local/openresty/bin/openresty
# 7 readelf -d /usr/local/openresty/bin/openresty
# https://github.com/openresty/docker-openresty/blob/master/alpine/Dockerfile