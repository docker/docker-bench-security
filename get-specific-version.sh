#!/bin/sh
if [ -n "${DBS_VERSION}" ]; then
  if [ ! -f /usr/share/docker-bench-security/${DBS_VERSION}.tar.gz ]; then
    echo "Getting docker-bench-security ${DBS_VERSION}..."
    wget -q -P /usr/share/docker-bench-security/ https://github.com/docker/docker-bench-security/archive/${DBS_VERSION}.tar.gz
    rm -rf /usr/share/docker-bench-security/${DBS_VERSION}/
    mkdir -p /usr/share/docker-bench-security/${DBS_VERSION}/
    tar xfzv /usr/share/docker-bench-security/${DBS_VERSION}.tar.gz -C /usr/share/docker-bench-security/${DBS_VERSION} --strip 1 --overwrite
    rm -rfv /usr/share/docker-bench-security/${DBS_VERSION}.tar.gz
  fi

  if [ $(find /usr/share/docker-bench-security/${DBS_VERSION}/ | wc -l) -gt 1  ]; then
    rm -rfv /usr/local/bin/docker-bench-security.sh /usr/local/bin/helper_lib.sh /usr/local/bin/output_lib.sh
    rm -rfv /usr/local/bin/tests/*

    cp -rv /usr/share/docker-bench-security/${DBS_VERSION}/*.sh /usr/local/bin/
    cp -rv /usr/share/docker-bench-security/${DBS_VERSION}/tests/*.sh /usr/local/bin/tests/
  fi
fi

exec "$@"