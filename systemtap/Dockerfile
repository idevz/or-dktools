FROM centos:7

# ---------------- #
#     Building     #
# ---------------- #

LABEL maintainer="idevz <zhoujing00k@gmail.com>"
LABEL KERNEL_SRC_URL="https://buildlogs.centos.org/c7.1708.00/kernel/20170822030048/3.10.0-693.el7.x86_64/"
ARG KERNEL_URL=https://buildlogs.centos.org/c7.1708.00/kernel/20170822030048/3.10.0-693.el7.x86_64
ARG KERNEL_VERSION=3.10.0-693.el7.x86_64

ADD ./kernel-rpms /tmp/kernel-rpms

RUN [ $(uname -r) == ${KERNEL_VERSION} ] \
    && yum --nogpgcheck -y install initscripts grubby linux-firmware perl-devel \
    yum -y remove kernel* \
    && cd /tmp/kernel-rpms \
    && yum -y localinstall ./kernel-${KERNEL_VERSION}.rpm \
    ./kernel-headers-${KERNEL_VERSION}.rpm \
    ./kernel-devel-${KERNEL_VERSION}.rpm \
    ./kernel-debug-devel-${KERNEL_VERSION}.rpm \
    ./kernel-tools-libs-${KERNEL_VERSION}.rpm \
    ./kernel-tools-${KERNEL_VERSION}.rpm \
    ./kernel-debuginfo-common-x86_64-${KERNEL_VERSION}.rpm \
    ./kernel-debuginfo-${KERNEL_VERSION}.rpm \
    && yum --nogpgcheck -y install systemtap systemtap-runtime \
    && cd / && rm -rf /tmp/kernel-rpms

# RUN [ $(uname -r) == ${KERNEL_VERSION} ] \
#     && yum --nogpgcheck -y install initscripts grubby linux-firmware perl-devel \
