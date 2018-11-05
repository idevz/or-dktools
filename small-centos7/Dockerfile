FROM centos:7

RUN yum install -y sudo make gcc nmon tree tcpdump\
    psmisc zsh git net-tools which;\
    rpm -e --nodeps systemd \
    && yum remove -y  \
    dracut* \
    # passwd* iputils* hostname* rootfiles* \
    acl* bind-license* cryptsetup-libs* \
    dbus* kpartx* dbus-python* \
    kmod-libs* device-mapper* \
    python-gobject-base* qrencode-libs* vim-minimal* \
    && yum autoremove -y \
    && yum clean all ;


FROM scratch
COPY --from=0 / /

CMD ["/bin/bash"]