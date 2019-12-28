FROM ubuntu:bionic

LABEL maintainer="chris.bensch@gmail.com"
# Forked from Bannsec

ARG DEBIAN_FRONTEND=noninteractive

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV PATH /opt/autopsy/bin:${JAVA_HOME}/bin:$PATH

RUN apt-get update && apt-get install -y \
        apt-utils \
        curl \
        dnsutils \
        libafflib0v5 \
        libafflib-dev \
        libboost-all-dev \
        libboost-dev \
        libc3p0-java \
        libewf2 \
        libewf-dev \
        libpostgresql-jdbc-java \
        libpq5 \
        libsqlite3-dev \
        libvhdi1 \
        libvhdi-dev \
        libvmdk1 \
        libvmdk-dev \
        openjdk-8-jdk \
        openjfx \
        testdisk \
        unzip \
        wget \
        xauth \
        x11-apps \
        x11-utils \
        x11proto-core-dev \
        x11proto-dev \
        xkb-data \
        xorg-sgml-doctools \
        xtrans-dev \
    && rm -rf /var/lib/apt/lists/*

RUN RELEASE_PATH=`curl -sL https://github.com/sleuthkit/autopsy/releases/latest \
        | grep -Eo 'href=".*.zip' \
        | grep -v archive \
        | head -1 \
        | cut -d '"' -f 2` \
    && mkdir -p /opt \
    && cd /opt \
    && curl -L https://github.com/${RELEASE_PATH} > autopsy.zip \
    && mkdir autopsy \
    && unzip -d autopsy autopsy.zip \
    && mv autopsy/autopsy*/* autopsy/. \
    && rm autopsy.zip \
    && RELEASE_PATH=`curl -sL https://github.com/sleuthkit/sleuthkit/releases/latest \
        | grep -Eo 'href=".*\.deb' \
        | grep -v archive \
        | head -1 \
        | cut -d '"' -f 2` \
    && curl -L https://github.com/${RELEASE_PATH} > tsk_java.deb \
    && dpkg -i tsk_java.deb \
        || apt-get install -fy \
    && rm tsk_java.deb \
    && apt -y autoremove \
    && apt autoclean \
    && cd /opt/autopsy*/ \
    && sh ./unix_setup.sh

ENTRYPOINT ["autopsy"]
