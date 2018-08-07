FROM centos:7

FROM scratch
COPY --from=0 /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=0 /lib64/libc.so.6 /lib64/libc.so.6
COPY --from=0 /lib64/libdl.so.2 /lib64/libdl.so.2
COPY --from=0 /lib64/libtinfo.so.5 /lib64/libtinfo.so.5
COPY --from=0 /bin/bash /bin/bash
COPY --from=0 /usr/bin/echo /usr/bin/echo


COPY --from=0 /etc/profile /etc/profile
COPY --from=0 /usr/bin/perl /usr/bin/perl
COPY --from=0 /usr/local/openresty /usr/local/openresty
COPY --from=0 /entrypoint.sh /entrypoint.sh

CMD ["/bin/bash"]