FROM centos:7

# ---------------- #
#     Building     #
# ---------------- #

LABEL maintainer="idevz <zhoujing00k@gmail.com>"
LABEL RUN="docker run -it --privileged --name NAME IMAGE"

ARG OR_ENV

# COPY builds /tmp/builds
# COPY builds/v-or.sh /tmp/builds/v-or.sh

# RUN /tmp/builds/v-or.sh && rm -rf /tmp/builds
RUN curl -fsSL http://172.17.0.1/builds/base.sh -o /base.sh \
    && chmod +x /base.sh \
    && curl -fsSL http://172.17.0.1/builds/v-or.sh | sh - \
    && echo "ok"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]