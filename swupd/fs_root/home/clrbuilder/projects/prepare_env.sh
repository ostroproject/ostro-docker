#!/bin/sh -xe

PROJ_DIR=/home/clrbuilder/projects
PROXY_OPT=

if [ -n "${http_proxy}" ]; then
    PROXY_OPT="-x http_proxy=${http_proxy}"
fi

dnf --assumeyes --allowerasing install \
    hostname \
    which \
    hardlink \
    openssl \
    bzip2 \
    cpio \
    xz \
    rsync \
    libtool \
    pkgconfig \
    glib2-devel \
    zlib-devel \
    openssl-devel \
    file-devel \
    xz-devel \
    bzip2-devel \
    make patch



cd $PROJ_DIR
mkdir swupd-server
curl ${PROXY_OPT} -L https://download.clearlinux.org/releases/5940/clear/source/SRPMS/swupd-server-2.53-4.src.rpm | \
    rpm2cpio - | \
    cpio -iu --to-stdout swupd-server-2.53.tar.gz | \
    tar xzf - -C swupd-server --strip-components=1
cat patches/*.patch | patch -p1 -d swupd-server
cd swupd-server
autoreconf -fi
./configure --enable-bsdtar
make
mkdir -p /var/lib/update

dnf --assumeyes remove \
    libtool \
    pkgconfig \
    glib2-devel \
    zlib-devel \
    openssl-devel \
    file-devel \
    xz-devel \
    bzip2-devel \
    make patch

dnf --assumeyes --exclude="openssl bsdtar rsync" autoremove
dnf --assumeyes install openssl bsdtar rsync
