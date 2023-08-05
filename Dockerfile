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
        /cdemu/libmirage11_*.deb \
        /cdemu/gir*.deb \
        /cdemu/libmirage11-dev*.deb

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

FROM debian:stable-slim

COPY --from=builder \
        /build/vhba-dkms*.deb \
        /build/libmirage_*.deb \
        /build/cdemu-daemon_*.deb \
        /build/cdemu-client_*.deb \
        /build/gcdemu*.deb \
        /build/gir*.deb \
        /build/image-analyzer*.deb \
        /build/

ENTRYPOINT ['tail', '-f', '/dev/null']
