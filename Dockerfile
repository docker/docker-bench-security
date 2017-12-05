FROM alpine:3.6

LABEL org.label-schema.name="docker-bench-security" \
      org.label-schema.url="https://dockerbench.com" \
      org.label-schema.vcs-url="https://github.com/docker/docker-bench-security.git"

# Switch to the HTTPS endpoint for the apk repositories as per https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories

RUN \
  apk upgrade --no-cache && \
  apk add --no-cache \
    docker \
    dumb-init && \
  rm -rf /usr/bin/docker-* /usr/bin/dockerd && \
  mkdir /usr/local/bin/tests

COPY ./*.sh /usr/local/bin/

COPY ./tests/*.sh /usr/local/bin/tests/

WORKDIR /usr/local/bin

HEALTHCHECK CMD exit 0

ENTRYPOINT [ "/usr/bin/dumb-init", "docker-bench-security.sh" ]

