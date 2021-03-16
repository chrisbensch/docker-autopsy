FROM ubuntu:focal

LABEL maintainer="chris.bensch@gmail.com"
# Forked from Bannsec

ARG DEBIAN_FRONTEND=noninteractive

ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle
ENV PATH /opt/autopsy/bin:${JAVA_HOME}/bin:$PATH

RUN mkdir -p /etc/apt/apt.conf.d && touch /etc/apt/apt.conf.d/80-retries
RUN echo "APT::Acquire::Retries \"3\";" > /etc/apt/apt.conf.d/80-retries

RUN \
  apt-get update && apt-get install -y \
  apt-utils \
  software-properties-common \
  curl \
  dnsutils \
  git \
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
  #openjdk-8-jdk \
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

# Install Oracle Java 8 - this fixed everything
RUN \
  add-apt-repository -y ppa:ts.sch.gr/ppa && \
  apt-get update

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/cache/oracle-jdk8-installer

RUN \
  groupadd -r analyst && useradd -r -g analyst analyst

WORKDIR /home/analyst 

RUN RELEASE_PATH=`curl -sL https://github.com/sleuthkit/autopsy/releases/latest \
  | grep -Eo 'href=".*.zip' \
  | grep -v archive \
  | head -1 \
  | cut -d '"' -f 2` \
  && cd /home/analyst \
  && curl -L https://github.com/sleuthkit/autopsy/releases/download/autopsy-4.17.0/autopsy-4.17.0.zip > autopsy.zip \
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
  && apt autoclean

RUN \
  mkdir -p /home/analyst/.autopsy/dev/python_modules \
  && cd /home/analyst/.autopsy/dev/python_modules \
  && git clone https://github.com/markmckinnon/Autopsy-Plugins.git \
  && cd Autopsy-Plugins \
  && rm README.md \
  && rm -rf img \
  && mv -n * ../ \
  && cd .. \
  && rm -rf Autopsy-Plugins \
  && cd /home/analyst/autopsy*/ \
  && sh ./unix_setup.sh

RUN \
  chown -R analyst:analyst /home/analyst

USER analyst
WORKDIR /home/analyst

#ENTRYPOINT ["autopsy"]