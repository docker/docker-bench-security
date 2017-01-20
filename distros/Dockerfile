FROM alpine:3.5

LABEL org.label-schema.name="docker-bench-security" \
      org.label-schema.url="https://dockerbench.com" \
      org.label-schema.vcs-url="https://github.com/docker/docker-bench-security.git"

RUN \
  apk add --no-cache \
    docker \
    dumb-init \
    git && \
  git clone https://github.com/docker/docker-bench-security.git /tmp/bench-security && \
  cp /tmp/bench-security/*.sh /usr/local/bin && \
  cp -R /tmp/bench-security/tests /usr/local/bin && \
  rm -rf /tmp/*

WORKDIR /usr/local/bin

ENTRYPOINT [ "/usr/bin/dumb-init", "docker-bench-security.sh" ]

