FROM alpine:3@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1

LABEL \
  org.label-schema.name="docker-bench-security" \
  org.label-schema.url="https://dockerbench.com" \
  org.label-schema.vcs-url="https://github.com/docker/docker-bench-security.git"

RUN apk add --no-cache iproute2 \
  docker-cli \
  dumb-init \
  jq \
  bash

COPY . /usr/local/bin/

HEALTHCHECK CMD exit 0

WORKDIR /usr/local/bin

ENTRYPOINT [ "/usr/bin/dumb-init", "/bin/bash", "docker-bench-security.sh" ]
CMD [""]
