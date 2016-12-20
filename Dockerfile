FROM alpine:3.2

LABEL org.label-schema.name="docker-bench-security" \
      org.label-schema.url="https://dockerbench.com" \
      org.label-schema.vcs-url="https://github.com/docker/docker-bench-security.git"

ENV VERSION 1.10.0

WORKDIR /usr/bin

RUN apk update && \
    apk upgrade && \
    apk --update add curl && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION > docker-$VERSION && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION.sha256 > docker-$VERSION.sha256 && \
    sha256sum -c docker-$VERSION.sha256 && \
    ln -s docker-$VERSION docker && \
    chmod u+x docker-$VERSION && \
    apk del curl && \
    rm -rf /var/cache/apk/*

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/bin/sh", "docker-bench-security.sh"]
