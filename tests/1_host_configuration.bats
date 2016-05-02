#!/usr/bin/env bats

setup() {
  . "$BATS_TEST_DIRNAME/../helper_lib.sh"
}

# 1.1
@test "1.1  - Create a separate partition for containers" {
  grep /var/lib/docker /etc/fstab
  [ $status -eq 0 ]
}

# 1.2
@test "1.2  - Use an updated Linux Kernel" {
  kernel_version=$(uname -r | cut -d "-" -f 1)
  run do_version_check 3.10 "$kernel_version"
  [ $status -eq 9 ] || [ $status -eq 10 ]
}

# 1.4
@test "1.4  - Remove all non-essential services from the host - Network" {
  # Check for listening network services.
  listening_services=$(netstat -na | grep -v tcp6 | grep -v unix | grep -c LISTEN)
  if [ "$listening_services" -eq 0 ]; then
    echoerr "1.4  - Failed to get listening services for check: $BATS_TEST_NAME"
  else
    if [ "$listening_services" -gt 5 ]; then
      echoerr "     * Host listening on: $listening_services ports"
    fi
  fi
  [ "$listening_services" -ne 0 ] && [ "$listening_services" -le 5 ]
}

# 1.5
@test "1.5  - Keep Docker up to date" {
  docker_version=$(docker version | grep -i -A1 '^server' | grep -i 'version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
  docker_current_version="1.11.1"
  docker_current_date="2016-04-27"
  run do_version_check "$docker_current_version" "$docker_version"
  if [ $status -eq 11 ]; then
    echoerr "      * Using $docker_version, when $docker_current_version is current as of $docker_current_date"
    echoerr "      * Your operating system vendor may provide support and security maintenance for docker"
  else
    pass "$check_1_5"
    echoerr "      * Using $docker_version which is current as of $docker_current_date"
    echoerr "      * Check with your operating system vendor for support and security maintenance for docker"
  fi
  [ $status -eq 9 ] || [ $status -eq 10 ]
}

# 1.6
@test "1.6  - Only allow trusted users to control Docker daemon" {
  docker_users=$(getent group docker)
  echoerr "$BATS_TEST_NAME"
  for u in $docker_users; do
    echoerr "     * $u"
  done
}

# 1.7
@test "1.7  - Audit docker daemon - /usr/bin/docker" {
  file="/usr/bin/docker"
  run command -v auditctl
  if [ $status -eq 0 ]; then
    auditctl -l | grep "$file" >/dev/null 2>&1
  else
    echoerr "      * Failed to inspect: auditctl command not found."
  fi
  [ $status -eq 0 ]
}

# 1.8
@test "1.8  - Audit Docker files and directories - /var/lib/docker" {
  skip "TODO: need to implement"
}

# 1.9
@test "1.9  - Audit Docker files and directories - /etc/docker" {
  skip "TODO: need to implement"
}

# 1.10
@test "1.10 - Audit Docker files and directories - docker.service" {
  skip "TODO: need to implement"
}

# 1.11
@test "1.11 - Audit Docker files and directories - docker.socket" {
  skip "TODO: need to implement"
}

# 1.12
@test "1.12 - Audit Docker files and directories - /etc/default/docker" {
  skip "TODO: need to implement"
}

# 1.13
@test "1.13 - Audit Docker files and directories - /etc/docker/daemon.json" {
  skip "TODO: need to implement"
}

# 1.14
@test "1.14 - Audit Docker files and directories - /usr/bin/docker-containerd" {
  skip "TODO: need to implement"
}

# 1.15
@test "1.15 - Audit Docker files and directories - /usr/bin/docker-runc" {
  skip "TODO: need to implement"
}
