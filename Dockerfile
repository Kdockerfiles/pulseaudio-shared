FROM alpine:3.11
LABEL maintainer="KenjiTakahashi <kenji.sx>"

RUN apk add --no-cache \
    meson \
    gcc \
    libc-dev \
    g++ \
    gettext-dev \
    libtool \
    tdb-dev \
    libsndfile-dev \
    m4 \
    alsa-lib-dev \
    speexdsp-dev \
    linux-headers \
    curl \
    libcap-dev

COPY *.patch /home/

ARG PA_VERSION=13.0

RUN curl -Lo/home/pa.tar.xz https://freedesktop.org/software/pulseaudio/releases/pulseaudio-${PA_VERSION}.tar.xz && \
    tar xvf /home/pa.tar.xz -C /home && \
    cd /home/pulseaudio-${PA_VERSION} && \
    patch -Np1 < ../link-libintl.patch && \
    meson \
        --prefix=/usr/local \
        --sysconfdir=/usr/local/etc \
        --localstatedir=/var \
        --optimization=s \
        --buildtype=release \
        -Dman=false \
        -Dtests=false \
        -Dlegacy-database-entry-format=false \
        -Davahi=disabled \
        -Dbluez5=false \
        -Ddbus=disabled \
        -Dgsettings=disabled \
        -Dgtk=disabled \
        -Dhal-compat=false \
        -Dsystemd=disabled \
        -Dx11=disabled \
        . output \
    && \
    ninja -C output && \
    ninja -C output install

# auth-anonymous=1
RUN sed -i 's,load-module module-native-protocol-unix,& socket=/tmp/pulse/socket auth-group=root,g' /usr/local/etc/pulse/default.pa
RUN sed -i 's,; default-server =,default-server = unix:/tmp/pulse/socket,g' /usr/local/etc/pulse/client.conf
RUN sed -i 's,; autospawn = yes,autospawn = no,g' /usr/local/etc/pulse/client.conf
RUN sed -i 's,; exit-idle-time = 20,exit-idle-time = -1,g' /usr/local/etc/pulse/daemon.conf


FROM alpine:3.11

COPY --from=0 /usr/local/ /usr/local/
