# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM debian:buster

# get the latest fixes
# install LibreOffice run-time dependencies
# install adduser, findutils, openssl and cpio that we need later
# install an editor
# tdf#117557 - Add CJK Fonts to Collabora Online Docker Image
RUN apt-get update && \
    apt-get -y install libpng16-16 fontconfig adduser cpio \
               findutils nano libcap2-bin openssl inotify-tools \
               procps libubsan0 libubsan1 openssh-client fonts-wqy-zenhei \
               fonts-wqy-microhei fonts-droid-fallback fonts-noto-cjk


# copy freshly built LOKit and Collabora Online
COPY /instdir /

# copy the shell script which can start Collabora Online (coolwsd)
COPY /start-collabora-online.sh /
COPY /start-collabora-online.pl /

# set up Collabora Online (normally done by postinstall script of package)
# Fix permissions
RUN setcap cap_fowner,cap_chown,cap_mknod,cap_sys_chroot=ep /usr/bin/coolforkit && \
    setcap cap_sys_admin=ep /usr/bin/coolmount && \
    adduser --quiet --system --group --home /opt/cool cool && \
    rm -rf /opt/cool && \
    mkdir -p /opt/cool/child-roots && \
    coolwsd-systemplate-setup /opt/cool/systemplate /opt/lokit >/dev/null 2>&1 && \
    touch /var/log/coolwsd.log && \
    chown cool:cool /var/log/coolwsd.log && \
    chown -R cool:cool /opt/ && \
    chown -R cool:cool /etc/coolwsd

EXPOSE 9980

# switch to cool user (use numeric user id to be compatible with Kubernetes Pod Security Policies)
USER 101

CMD ["/start-collabora-online.sh"
