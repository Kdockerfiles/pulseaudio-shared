FROM alpine:3.10
LABEL maintainer="KenjiTakahashi <kenji.sx>"

RUN apk add --no-cache \
    autoconf \
    automake \
    curl \
    file \
    gcc \
    gettext-dev \
    git \
    intltool \
    libc-dev \
    libcap-dev \
    libsndfile-dev \
    libtool \
    make \
    speexdsp-dev \
    alsa-lib-dev

COPY *.patch /home/

ARG PA_VERSION=12.2

RUN curl -Lo/home/pa.tar.xz https://freedesktop.org/software/pulseaudio/releases/pulseaudio-${PA_VERSION}.tar.xz && \
    tar xvf /home/pa.tar.xz -C /home && \
    cd /home/pulseaudio-${PA_VERSION} && \
    patch -Np1 < ../b89d33bb182c42db5ad3987b0e91b7bf62f421e8.patch && \
    autopoint --force && \
    AUTOPOINT='intltoolize --automake --copy --force' autoreconf -if && \
    ./configure \
        --prefix=/usr/local \
        --sysconfdir=/usr/local/etc \
        --mandir=/usr/local/share/man \
        --localstatedir=/var \
        --disable-udev \
        --disable-hal-compat \
        --disable-nls \
        --disable-oss-output \
        --disable-coreaudio-output \
        --disable-esound \
        --disable-solaris \
        --disable-gconf \
        --disable-avahi \
        --disable-manpages \
        --disable-x11 \
        --disable-gtk3 \
        --disable-legacy-database-entry-format \
    && \
    make && \
    make -j1 install

# auth-anonymous=1
RUN sed -i 's,load-module module-native-protocol-unix,& socket=/tmp/pulse/socket auth-group=root,g' /usr/local/etc/pulse/default.pa
RUN sed -i 's,; default-server =,default-server = unix:/tmp/pulse/socket,g' /usr/local/etc/pulse/client.conf
RUN sed -i 's,; autospawn = yes,autospawn = no,g' /usr/local/etc/pulse/client.conf
RUN sed -i 's,; exit-idle-time = 20,exit-idle-time = -1,g' /usr/local/etc/pulse/daemon.conf


FROM alpine:3.10

COPY --from=0 /usr/local/ /usr/local/
