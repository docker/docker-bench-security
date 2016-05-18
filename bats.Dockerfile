# REPOSITORY https://github.com/docker/docker-bench-securit
FROM alpine:3.3

MAINTAINER dockerbench.com
MAINTAINER Alexei Ledenev <alexei.led@gmail.com>

ENV VERSION 1.11.1
ENV BATS_VERSION 0.4.0
ENV BATS_SHA_256 480d8d64f1681eee78d1002527f3f06e1ac01e173b761bc73d0cf33f4dc1d8d7

LABEL docker_bench_security=true

RUN apk --update add curl bash ncurses \
    && rm -rf /var/lib/apt/lists/* \
    && rm /var/cache/apk/*

RUN curl -o "/tmp/v${BATS_VERSION}.tar.gz" -LS "https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz" && \
    echo "${BATS_SHA_256}  v${BATS_VERSION}.tar.gz" > /tmp/v${BATS_VERSION}.tar.gz.sha256 && \
    cd /tmp && sha256sum -c v${BATS_VERSION}.tar.gz.sha256 && \
    tar -xvzf "/tmp/v${BATS_VERSION}.tar.gz" -C /tmp/ && \
    bash "/tmp/bats-${BATS_VERSION}/install.sh" /usr/local && \
    rm -rf /tmp/*

RUN curl -o "/tmp/docker-$VERSION.tgz" -LS "https://get.docker.com/builds/Linux/x86_64/docker-$VERSION.tgz" && \
    curl -o "/tmp/docker-$VERSION.tgz.sha256" -LS "https://get.docker.com/builds/Linux/x86_64/docker-$VERSION.tgz.sha256" && \
    cd /tmp && sha256sum -c docker-$VERSION.tgz.sha256 && \
    tar -xvzf "/tmp/docker-$VERSION.tgz" -C /tmp/ && \
    chmod u+x /tmp/docker/docker && mv /tmp/docker/docker /usr/bin/ && \
    rm -rf /tmp/*


RUN mkdir /docker-bench-security

COPY . /docker-bench-security
RUN chmod +x /docker-bench-security/run_tests.sh

WORKDIR /docker-bench-security

VOLUME /var/docker-bench

CMD ["-r"]
ENTRYPOINT ["./run_tests.sh"]
