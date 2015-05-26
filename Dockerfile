FROM gliderlabs/alpine:3.1

RUN apk --update add docker

RUN mkdir /docker-bench

COPY . /docker-bench

WORKDIR /docker-bench

ENTRYPOINT ["/bin/sh", "docker-bench.sh"]
