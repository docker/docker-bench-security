FROM alpine:3.5

ENV DBS_VERSION=

LABEL org.label-schema.name="docker-bench-security" \
      org.label-schema.url="https://dockerbench.com" \
      org.label-schema.vcs-url="https://github.com/docker/docker-bench-security.git"

RUN \
  apk upgrade --no-cache && \
  apk add --no-cache \
    docker \
    dumb-init \
    openssl && \
  rm -rf /usr/bin/docker-* /usr/bin/dockerd && \
  mkdir /usr/local/bin/tests && \
  mkdir /usr/share/docker-bench-security

COPY ./*.sh /usr/local/bin/

COPY ./tests/*.sh /usr/local/bin/tests/

WORKDIR /usr/local/bin

HEALTHCHECK CMD exit 0

ENTRYPOINT [ "/usr/bin/dumb-init", "get-specific-version.sh", "docker-bench-security.sh" ]