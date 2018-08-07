ARG OR_BASE_IMGE
FROM ${OR_BASE_IMGE} AS idevz_or

# FROM centos:7
FROM zhoujing/centos
ARG OR_ENV
ARG OR_PREFIX
ARG OPEN
ARG IGLB

ENV OR_ENV=${OR_ENV}
ENV OR_PREFIX=${OR_PREFIX}
# ---------------- #
#     Building     #
# ---------------- #

COPY --from=idevz_or /etc/profile /etc/profile
COPY --from=idevz_or /usr/bin/gdb /usr/bin/gdb
COPY --from=idevz_or /usr/bin/perl /usr/bin/perl

COPY --from=idevz_or ${OR_PREFIX} ${OR_PREFIX}
COPY --from=idevz_or /entrypoint.sh /entrypoint.sh
COPY --from=idevz_or /usr/local/bin/run /usr/local/bin/run
COPY --from=idevz_or /usr/local/bin/luajit_prove /usr/local/bin/luajit_prove

LABEL maintainer="idevz <zhoujing00k@gmail.com>"
LABEL RUN="docker run -it --privileged --name NAME IMAGE"



COPY /scripts /tmp/scripts

RUN yum install --nogpgcheck -y make gcc perl-ExtUtils-Embed \
    && curl -fSL http://xrl.us/cpanm -o /usr/bin/cpanm && chmod +x /usr/bin/cpanm \
    && cpanm --force Test::Nginx  Digest::SHA \
    && /tmp/scripts/or-motan.sh \
    && rm -rf ~/.cpanm/* \
    && yum remove -y make gcc perl-ExtUtils-Embed \
    && yum autoremove -y \
    && yum clean all \
    # && yum install -y setup \
    && [ -f /etc/shadow.rpmsave ] && mv /etc/shadow.rpmsave /etc/shadow \
    && [ -f /etc/profile.rpmsave ] && mv /etc/profile.rpmsave /etc/profile \
    && [ -f /etc/passwd.rpmsave ] && mv /etc/passwd.rpmsave /etc/passwd \
    && [ -f /etc/gshadow.rpmsave ] && mv /etc/gshadow.rpmsave /etc/gshadow \
    && [ -f /etc/group.rpmsave ] && mv /etc/group.rpmsave /etc/group

ENTRYPOINT ["/entrypoint.sh"]

CMD ["${OR_PREFIX}/bin/openresty", "-g", "daemon off;"]