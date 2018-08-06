ARG OR_BASE_IMGE="registry.api.weibo.com/openapi_rd/openresty"
FROM ${OR_BASE_IMGE}

# ---------------- #
#     Building     #
# ---------------- #

LABEL maintainer="idevz <zhoujing00k@gmail.com>"
LABEL RUN="docker run -it --privileged --name NAME IMAGE"

ARG OR_ENV
ARG OPEN
ARG IGLB

COPY /scripts /tmp/scripts

RUN /tmp/scripts/or-motan.sh

# ENTRYPOINT ["/entrypoint.sh"]

# CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]