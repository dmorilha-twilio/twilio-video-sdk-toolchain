#!/bin/bash

set -e -u -x
DOCKERFILE=Dockerfile
cat >$DOCKERFILE <<EOF
FROM debian:stretch

USER root

RUN dpkg --add-architecture armhf \
    && apt -y update \
    && apt -y install \
        binutils-arm-linux-gnueabihf \
        curl \
        ffmpeg \
        file \
        g++-arm-linux-gnueabihf \
        gcc \
        gcc-arm-linux-gnueabihf \
        gdb \
        git \
        iproute2 \
        iptables \
        less \
        libasound2-dev:armhf \
        libaudio-dev:armhf \
        libgtk2.0-dev \
        libpulse-dev \
        libstdc++-6-dev:armhf \
        libx11-dev \
        libx11-dev:armhf \
        libxcomposite-dev \
        libxcomposite-dev:armhf \
        libxext-dev \
        libxext-dev:armhf \
        libxml2-dev \
        libxml2:armhf \
        libxrender-dev \
        libxrender-dev:armhf \
        libz-dev \
        openjdk-8-jre \
        pkg-config \
        python-pip \
        rsync \
        ruby-dev \
        vim \
        wget

RUN cd /tmp \
    && mkdir -pv /opt/cmake /opt/maven /opt/twilio/ \
    && wget 'https://cmake.org/files/v3.14/cmake-3.14.3-Linux-x86_64.sh' \
    && chmod a+x cmake-3.14.3-Linux-x86_64.sh \
    && ./cmake-3.14.3-Linux-x86_64.sh --exclude-subdir --skip-license --prefix=/opt/cmake \
    && ln -sf /opt/cmake/bin/cmake /usr/bin/ \
    && wget https://archive.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz \
    && tar xvf apache-maven-3.5.4-bin.tar.gz -C /opt/maven \
    && ln -sf /opt/maven/apache-maven*/bin/mvn /usr/bin \
    && wget https://twilio.bintray.com/releases/com/twilio/sdk/twilio-llvm-linux/0.1/twilio-llvm-linux-0.1-linux.tar.bz2 \
    && tar xvf ./twilio-llvm-linux-0.1-linux.tar.bz2 -C /opt/twilio \
    && bash -c 'ln -sf /opt/twilio/llvm-linux/bin/{clang,clang++,ld.lld,lld,lld-link,llvm-ar,llvm-symbolizer,sancov} /usr/bin/'

COPY qemu-arm /usr/bin/

WORKDIR /opt/twilio

CMD /bin/bash
EOF

REVISION=`git rev-parse HEAD``git diff-index --quiet HEAD -- || echo '-dirty'`

set +u

docker build --file $DOCKERFILE --tag twilio/twilio-video-sdk-toolchain:$REVISION --tag twilio/twilio-video-sdk-toolchain:latest .
