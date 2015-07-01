# REPOSITORY https://github.com/konstruktoid/docker-bench-security/

FROM debian:wheezy

MAINTAINER Thomas Sjögren <konstruktoid@users.noreply.github.com>

RUN \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install auditd ca-certificates curl \
      gawk net-tools procps --no-install-recommends && \
    curl -sSL https://get.docker.com/ | sh && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* \
      /usr/share/doc /usr/share/doc-base \
      /usr/share/man /usr/share/locale /usr/share/zoneinfo

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/bin/sh", "docker-bench-security.sh"]
