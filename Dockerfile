FROM debian:bullseye as builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        dpkg-dev \
        debhelper \
        dkms \
        pkg-config \
        libglib2.0-dev \
        libsndfile1-dev \
        libsamplerate0-dev \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        gtk-doc-tools \
        gobject-introspection \
        libgirepository1.0-dev \
        intltool \
        cmake \
        libao-dev \
        dh-python \
        bash-completion

RUN mkdir -p /cdemu
COPY . /cdemu
       
WORKDIR /cdemu/vhba-module
RUN dpkg-buildpackage -b -uc -tc
      
WORKDIR /cdemu/libmirage
RUN dpkg-buildpackage -b -uc -tc

# cdemu-daemon builder requires libmirage to be present in the system
RUN apt install -y \
        /cdemu/libmirage11_3.2.6-1_amd64.deb \
        /cdemu/gir1.2-mirage-3.2_3.2.6-1_amd64.deb \
        /cdemu/libmirage11-dev_3.2.6-1_amd64.deb

WORKDIR /cdemu/cdemu-daemon
RUN dpkg-buildpackage -b -uc -tc
        
WORKDIR /cdemu/cdemu-client
RUN dpkg-buildpackage -b -uc -tc

WORKDIR /cdemu/gcdemu
RUN dpkg-buildpackage -b -uc -tc

WORKDIR /cdemu/image-analyzer
RUN dpkg-buildpackage -b -uc -tc

RUN mkdir /build \
    && cp /cdemu/*.deb /build

FROM debian:bullseye

COPY --from=builder \
        /build/vhba-dkms_20211218-1_all.deb \
        /build/libmirage11_3.2.6-1_amd64.deb \
        /build/cdemu-daemon_3.2.6-1_amd64.deb \
        /build/cdemu-client_3.2.5-1_all.deb \
        /build/gcdemu_3.2.6-1_all.deb \
        /build/

ENTRYPOINT ['tail', '-f', '/dev/null']


