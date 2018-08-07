FROM centos:7

# ---------------- #
#     Building     #
# ---------------- #

LABEL maintainer="idevz <zhoujing00k@gmail.com>"
LABEL RUN="docker run -it --privileged --name NAME IMAGE"

ARG GFW 
ARG OR_ENV 
ARG DOCKER
ARG STAP

ARG OR_PREFIX
ARG RESTY_VERSION
ARG RESTY_LUAROCKS_VERSION
ARG RESTY_OPENSSL_VERSION
ARG RESTY_PCRE_VERSION
ARG RESTY_ZLIB_VERSION
ARG RESTY_J


COPY /scripts /tmp/scripts

RUN /tmp/scripts/v-or.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]