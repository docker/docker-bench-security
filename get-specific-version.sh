#!/bin/sh
if [ -n "${DBS_VERSION}" ]; then
  if [ ! -f /usr/share/docker-bench-security/v${DBS_VERSION}.tar.gz ]; then
    echo "Getting docker-bench-security v${DBS_VERSION}..."
    wget -q -P /usr/share/docker-bench-security/ https://github.com/docker/docker-bench-security/archive/v${DBS_VERSION}.tar.gz
    rm -rf /usr/share/docker-bench-security/docker-bench-security-${DBS_VERSION}/
    tar xfz /usr/share/docker-bench-security/v${DBS_VERSION}.tar.gz -C /usr/share/docker-bench-security/
  fi
  
  if [ -d /usr/share/docker-bench-security/docker-bench-security-${DBS_VERSION}/ ]; then
    rm -rf /usr/local/bin/docker-bench-security.sh /usr/local/bin/helper_lib.sh /usr/local/bin/output_lib.sh
    rm -rf /usr/local/bin/tests/*
  
    cp -r /usr/share/docker-bench-security/docker-bench-security-${DBS_VERSION}/*.sh /usr/local/bin/
    cp -r /usr/share/docker-bench-security/docker-bench-security-${DBS_VERSION}/tests/*.sh /usr/local/bin/tests/
  fi
fi

exec "$@"