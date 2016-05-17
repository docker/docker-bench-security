#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "$BATS_TEST_DIRNAME/../helper_lib.sh"

# 1.1
@test "1.1  - Create a separate partition for containers" {
  run grep /var/lib/docker /etc/fstab
  assert_success
}

# 1.2
@test "1.2  - Use an updated Linux Kernel" {
  kernel_version=$(uname -r | cut -d "-" -f 1)
  run do_version_check 3.10 "$kernel_version"
  assert [ $status -eq 9 -o $status -eq 10 ]
}

# 1.4
@test "1.4  - Remove all non-essential services from the host - Network" {
  # Check for listening network services.
  listening_services=$(netstat -na | grep -v tcp6 | grep -v unix | grep -c LISTEN)
  if [ "$listening_services" -eq 0 ]; then
    fail "Failed to get listening services for check: $BATS_TEST_NAME"
  else
    if [ "$listening_services" -gt 5 ]; then
      fail "Host listening on: $listening_services ports"
    fi
  fi
}

# 1.5
@test "1.5  - Keep Docker up to date" {
  docker_version=$(docker version | grep -i -A1 '^server' | grep -i 'version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
  docker_current_version="1.11.1"
  docker_current_date="2016-04-27"
  run do_version_check "$docker_current_version" "$docker_version"
  if [ $status -eq 11 ]; then
    fail "Using $docker_version, when $docker_current_version is current as of $docker_current_date. Your operating system vendor may provide support and security maintenance for docker."
  fi
  assert [ $status -eq 9 -o $status -eq 10 ]
}

# 1.6
@test "1.6  - Only allow trusted users to control Docker daemon" {
  declare -a trusted_users=("vagrant" "docker" "ubuntu")
  users_string=$(awk -F':' '/^docker/{print $4}' /etc/group)
  docker_users=(${users_string//,/ })
  for u in ${docker_users[@]}; do
    local found=1
    for tu in ${trusted_users[@]}; do
      if [ "$u" = "$tu" ]; then
        found=0
      fi
    done
    if [ $found -eq 1 ]; then
      fail "User $u is not a trusted user!"
    fi
  done
}

# 1.7
@test "1.7  - Audit docker daemon - /usr/bin/docker" {
  file="/usr/bin/docker"
  run command -v auditctl
  assert_success
  run auditctl -l | grep "$file"
  assert_success
}

test_audit_directory() {
  local directory="$1"
  assert [ -d "$directory" ]
  run command -v auditctl >/dev/null
  assert_success
  run auditctl -l | grep $directory
  assert_success
}

test_audit_file() {
  file="$1"
  assert [ -f "$file" ]
  run command -v auditctl
  assert_success
  run auditctl -l | grep "$file"
  assert_success
}

# 1.8
@test "1.8  - Audit Docker files and directories - /var/lib/docker" {
  test_audit_directory "/var/lib/docker"
}

# 1.9
@test "1.9  - Audit Docker files and directories - /etc/docker" {
  test_audit_directory "/etc/docker"
}

# 1.10
@test "1.10 - Audit Docker files and directories - docker.service" {
  test_audit_file "$(get_systemd_service_file docker.service)"
}

# 1.11
@test "1.11 - Audit Docker files and directories - docker.socket" {
  test_audit_file "$(get_systemd_service_file docker.socket)"
}

# 1.12
@test "1.12 - Audit Docker files and directories - /etc/default/docker" {
  test_audit_file "/etc/default/docker"
}

# 1.13
@test "1.13 - Audit Docker files and directories - /etc/docker/daemon.json" {
  test_audit_file "/etc/docker/daemon.json"
}

# 1.14
@test "1.14 - Audit Docker files and directories - /usr/bin/docker-containerd" {
  test_audit_file "/usr/bin/docker-containerd"
}

# 1.15
@test "1.15 - Audit Docker files and directories - /usr/bin/docker-runc" {
  test_audit_file "/usr/bin/docker-runc"
}
