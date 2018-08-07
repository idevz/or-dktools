FROM centos:7

FROM scratch
COPY --from=0 /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=0 /lib64/libc.so.6 /lib64/libc.so.6
COPY --from=0 /lib64/libdl.so.2 /lib64/libdl.so.2
COPY --from=0 /lib64/libtinfo.so.5 /lib64/libtinfo.so.5
COPY --from=0 /bin/bash /bin/bash
COPY --from=0 /usr/bin/echo /usr/bin/echo

CMD ["/bin/bash"]