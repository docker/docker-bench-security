FROM gliderlabs/alpine:3.1

RUN apk --update add docker

RUN mkdir /docker_security_benchmark

COPY . /docker_security_benchmark

WORKDIR /docker_security_benchmark

ENTRYPOINT ["/bin/sh", "docker_security_benchmark.sh"]
