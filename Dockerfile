FROM alpine:3.1

RUN apk update && \
    apk upgrade && \
    apk --update add docker

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/bin/sh", "docker-bench-security.sh"]
