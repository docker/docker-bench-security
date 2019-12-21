FROM alpine:3.11

LABEL \
  org.label-schema.name="docker-bench-security" \
  org.label-schema.url="https://dockerbench.com" \
  org.label-schema.vcs-url="https://github.com/docker/docker-bench-security.git"

# Switch to the HTTPS endpoint for the apk repositories
# https://github.com/gliderlabs/docker-alpine/issues/184
RUN set -eux; \
  sed -i 's!http://dl-cdn.alpinelinux.org/!https://alpine.global.ssl.fastly.net/!g' /etc/apk/repositories && \
  apk add --no-cache \
    iproute2 \
    docker-cli \
    dumb-init

COPY ./*.sh /usr/local/bin/
COPY ./tests/*.sh /usr/local/bin/tests/

HEALTHCHECK CMD exit 0

WORKDIR /usr/local/bin

ENTRYPOINT [ "/usr/bin/dumb-init", "docker-bench-security.sh" ]
CMD [""]
