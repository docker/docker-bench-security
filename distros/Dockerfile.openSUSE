# REPOSITORY https://github.com/docker/docker-bench-security

FROM opensuse

MAINTAINER security@suse.com

RUN zypper -n in docker iproute2 audit

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/bin/sh", "docker-bench-security.sh"]
