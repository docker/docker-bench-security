# REPOSITORY https://github.com/fatherlinux/docker-bench-security

MAINTAINER smccarty@redhat.com

FROM centos

RUN yum install -y docker net-tools audit procps-ng; yum clean all

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/bin/sh", "docker-bench-security.sh"]
