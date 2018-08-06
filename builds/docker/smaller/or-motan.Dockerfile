FROM zhoujing/or-wmotan:debug AS or-wmotan

# FROM centos:7
FROM zhoujing/centos
# ---------------- #
#     Building     #
# ---------------- #

COPY --from=or-wmotan /usr/local/openresty-debug /usr/local/openresty-debug
COPY --from=or-wmotan /etc/profile /etc/profile
COPY --from=or-wmotan /usr/bin/gdb /usr/bin/gdb
COPY --from=or-wmotan /usr/bin/perl /usr/bin/perl
COPY --from=or-wmotan /entrypoint.sh /entrypoint.sh
COPY --from=or-wmotan /usr/local/bin/run /usr/local/bin/run
COPY --from=or-wmotan /usr/local/bin/luajit_prove /usr/local/bin/luajit_prove

LABEL maintainer="idevz <zhoujing00k@gmail.com>"
LABEL RUN="docker run -it --privileged --name NAME IMAGE"

ARG OR_ENV
ARG OPEN
ARG IGLB

COPY /scripts /tmp/scripts

RUN yum install --nogpgcheck -y make gcc perl-ExtUtils-Embed \
    && curl -fSL http://xrl.us/cpanm -o /usr/bin/cpanm && chmod +x /usr/bin/cpanm \
    && cpanm --force Test::Nginx  Digest::SHA \
    && /tmp/scripts/or-motan.sh \
    && rm -rf ~/.cpanm/* \
    && yum remove -y make gcc perl-ExtUtils-Embed \
    && yum autoremove -y \
    && yum clean all

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/openresty-debug/bin/openresty", "-g", "daemon off;"]