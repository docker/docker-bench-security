FROM alpine:3.18@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

LABEL \
  org.label-schema.name="docker-bench-security" \
  org.label-schema.url="https://dockerbench.com" \
  org.label-schema.vcs-url="https://github.com/docker/docker-bench-security.git"

RUN apk add --no-cache iproute2 \
    docker-cli \
    dumb-init \
    jq

COPY . /usr/local/bin/

HEALTHCHECK CMD exit 0

WORKDIR /usr/local/bin

ENTRYPOINT [ "/usr/bin/dumb-init", "/bin/sh", "docker-bench-security.sh" ]
CMD [""]
