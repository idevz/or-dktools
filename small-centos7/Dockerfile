FROM centos

RUN rpm -e --nodeps systemd \
    && yum remove -y  \
    dracut* \
    # passwd* iputils* hostname* rootfiles* \
    acl* bind-license* cryptsetup-libs* \
    dbus* kpartx* dbus-python* \
    kmod-libs* device-mapper* \
    python-gobject-base* qrencode-libs* vim-minimal* \
    && yum autoremove -y \
    && yum clean all 

FROM scratch
COPY --from=0 / /

CMD ["/bin/bash"]