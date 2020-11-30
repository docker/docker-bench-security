# REPOSITORY https://github.com/fatherlinux/docker-bench-security

FROM rhel7

MAINTAINER smccarty@redhat.com

RUN yum install -y yum-utils; yum clean all
RUN yum-config-manager --disable "*" &>/dev/null
RUN yum-config-manager --enable rhel-7-server-rpms --enable rhel-7-server-extras-rpms
RUN yum install -y docker iproute audit procps-ng; yum clean all

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/bin/sh", "docker-bench-security.sh"]
