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
        file \
        gcc \
        gdb \
        git \
        iproute2 \
        iptables \
        less \
        libasound2-dev:armhf \
        libaudio-dev:armhf \
        libicu-dev:armhf \
        libstdc++-6-dev:armhf \
        libx11-dev \
        libx11-dev:armhf \
        libxml2-dev:armhf \
        libz-dev \
        openjdk-8-jre \
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

`git ls-tree HEAD | cut -f 2 | sort | sed '/docker.sh/d' | while read source; do echo COPY $source $source; done`

WORKDIR /opt/twilio

CMD /bin/bash
EOF

REVISION=`git rev-parse HEAD``git diff-index --quiet HEAD -- || echo '-dirty'`

set +u

docker build --file $DOCKERFILE --tag dmorilha/twilio-video-sdk-toolchain:$REVISION --tag dmorilha/twilio-video-sdk-toolchain:latest .
