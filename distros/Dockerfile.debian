FROM debian:sid

LABEL org.label-schema.name="docker-bench-security" \
      org.label-schema.url="https://github.com/konstruktoid/docker-bench-security" \
      org.label-schema.vcs-url="https://github.com/konstruktoid/docker-bench-security.git"

RUN \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install auditd ca-certificates docker.io \
      gawk iproute2 procps --no-install-recommends && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* \
      /usr/share/doc /usr/share/doc-base \
      /usr/share/man /usr/share/locale /usr/share/zoneinfo

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/bin/sh", "docker-bench-security.sh"]
