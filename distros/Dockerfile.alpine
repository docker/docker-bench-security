# REPOSITORY https://github.com/docker/docker-bench-security

FROM alpine:3.2

MAINTAINER dockerbench.com

RUN apk update && \
    apk upgrade && \
    apk --update add docker

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/bin/sh", "docker-bench-security.sh"]
