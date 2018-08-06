FROM centos

RUN rpm -e --nodeps systemd \
    && yum remove -y  \
    dracut* \
    # passwd* iputils* hostname* rootfiles* \
    acl* bind-license* cryptsetup-libs* \
    dbus* kpartx* dbus-python* \
    kmod-libs* device-mapper* \
    python-gobject-base* qrencode-libs* vim-minimal* 
# \
# && yum clean all \
# && yum autoremove -y
# RUN yum remove -y  \
# dracut* iputils* \
# acl* bind-license* cryptsetup-libs* \
# dbus* kpartx* dbus-python* hostname* iputils* \
# kmod-libs* passwd* device-mapper* rootfiles*\
# python-gobject-base* qrencode-libs* vim-minimal* \


FROM scratch
COPY --from=0 / /

CMD ["/bin/bash"]