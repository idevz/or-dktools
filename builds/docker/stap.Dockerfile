FROM centos:7

# ---------------- #
#     Building     #
# ---------------- #

LABEL maintainer="idevz <zhoujing00k@gmail.com>"
LABEL RUN="docker run -it --privileged --name NAME IMAGE"

ARG GFW

COPY /scripts /tmp/scripts

RUN /tmp/scripts/stap.sh
