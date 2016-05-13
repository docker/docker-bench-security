# REPOSITORY https://github.com/docker/docker-bench-securit
FROM alpine:3.3

MAINTAINER dockerbench.com
MAINTAINER Alexei Ledenev <alexei.led@gmail.com>

ENV VERSION 1.10.0
ENV BATS_VERSION 0.4.0

WORKDIR /usr/bin

RUN apk update && \
    apk upgrade && \
    apk --update add curl bash && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION > docker-$VERSION && \
    curl -sS https://get.docker.com/builds/Linux/x86_64/docker-$VERSION.sha256 > docker-$VERSION.sha256 && \
    sha256sum -c docker-$VERSION.sha256 && \
    ln -s docker-$VERSION docker && \
    chmod u+x docker-$VERSION && \
    rm -rf /var/cache/apk/*

RUN curl -o "/tmp/v${BATS_VERSION}.tar.gz" -L \
		"https://github.com/sstephenson/bats/archive/v${BATS_VERSION}.tar.gz" \
	&& tar -x -z -f "/tmp/v${BATS_VERSION}.tar.gz" -C /tmp/ \
	&& bash "/tmp/bats-${BATS_VERSION}/install.sh" /usr/local \
	&& rm -rf /tmp/*

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/usr/local/bin/bats", "/docker-bench-security/test"]
