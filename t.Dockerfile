FROM centos:7

# ---------------- #
#     Building     #
# ---------------- #

LABEL maintainer="idevz <zhoujing00k@gmail.com>"
LABEL RUN="docker run -it --privileged --name NAME IMAGE"

ARG OR_ENV
COPY builds/pkgs/kernel-rpms /tmp/kernel-rpms

RUN yum install -y initscripts
RUN yum install -y grubby
RUN yum install -y linux-firmware
RUN yum install -y perl-devel

RUN yum -y localinstall /tmp/kernel-rpms/kernel-3.10.0-693.el7.x86_64.rpm
RUN yum -y localinstall /tmp/kernel-rpms/kernel-headers-3.10.0-693.el7.x86_64.rpm
RUN yum -y localinstall /tmp/kernel-rpms/kernel-devel-3.10.0-693.el7.x86_64.rpm
RUN yum -y localinstall /tmp/kernel-rpms/kernel-debug-devel-3.10.0-693.el7.x86_64.rpm
RUN yum -y localinstall /tmp/kernel-rpms/kernel-tools-libs-3.10.0-693.el7.x86_64.rpm
RUN yum -y localinstall /tmp/kernel-rpms/kernel-tools-3.10.0-693.el7.x86_64.rpm
RUN yum -y localinstall /tmp/kernel-rpms/kernel-debuginfo-common-x86_64-3.10.0-693.el7.x86_64.rpm
RUN yum -y localinstall /tmp/kernel-rpms/kernel-debuginfo-3.10.0-693.el7.x86_64.rpm
RUN yum --nogpgcheck -y install systemtap
RUN yum --nogpgcheck -y install systemtap-runtime

# ➜  or-dktools docker history zhoujing/t
# IMAGE               CREATED              CREATED BY                                      SIZE                COMMENT
# 996f77b5d7ae        5 seconds ago        /bin/sh -c yum --nogpgcheck -y install syste…   137MB
# 469e221a6b69        6 seconds ago        /bin/sh -c yum --nogpgcheck -y install syste…   206MB
# bc4bd15b6df0        About a minute ago   /bin/sh -c yum -y localinstall /tmp/kernel-r…   1.89GB
# c08c7af74244        2 minutes ago        /bin/sh -c yum -y localinstall /tmp/kernel-r…   336MB
# 2f178dc03216        2 minutes ago        /bin/sh -c yum -y localinstall /tmp/kernel-r…   120MB
# 9098409759ca        2 minutes ago        /bin/sh -c yum -y localinstall /tmp/kernel-r…   49.6MB
# a2a4ae875523        2 minutes ago        /bin/sh -c yum -y localinstall /tmp/kernel-r…   81.7MB
# d6b42fb3507d        2 minutes ago        /bin/sh -c yum -y localinstall /tmp/kernel-r…   73.5MB
# 0bd892dd93f9        2 minutes ago        /bin/sh -c yum -y localinstall /tmp/kernel-r…   27.9MB
# 0e4a365e19c7        2 minutes ago        /bin/sh -c yum -y localinstall /tmp/kernel-r…   81.2MB
# be77fa9ac38c        3 minutes ago        /bin/sh -c yum install -y perl-devel            133MB
# 01831891b674        3 minutes ago        /bin/sh -c yum install -y linux-firmware        263MB
# 5726f97e805f        5 minutes ago        /bin/sh -c yum install -y grubby                86.6MB
# 134641faf6a3        5 minutes ago        /bin/sh -c yum install -y initscripts           90.4MB
# a3a86e9dbae7        5 minutes ago        /bin/sh -c #(nop) COPY dir:1e8016311d2904b6f…   527MB
# 8af5b4c7b5a1        28 hours ago         /bin/sh -c #(nop)  ARG OR_ENV                   0B
# 4d35e66b5726        29 hours ago         /bin/sh -c #(nop)  LABEL RUN=docker run -it …   0B
# 9d90b2f46bca        4 days ago           /bin/sh -c #(nop)  LABEL maintainer=idevz <z…   0B
# 49f7960eb7e4        8 weeks ago          /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
# <missing>           8 weeks ago          /bin/sh -c #(nop)  LABEL org.label-schema.sc…   0B
# <missing>           8 weeks ago          /bin/sh -c #(nop) ADD file:8f4b3be0c1427b158…   200MB