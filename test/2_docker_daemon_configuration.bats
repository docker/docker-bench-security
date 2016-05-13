#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "$BATS_TEST_DIRNAME/../helper_lib.sh"

# 2.1
@test "2.1  - Restrict network traffic between containers" {
  result=$(get_docker_effective_command_line_args '--icc')
  run grep "false" <<< "$result"
  assert_success
}

# 2.2
@test "2.2  - Set the logging level" {
  result=$(get_docker_effective_command_line_args '-l')
  run grep 'debug' <<< "$result"
  assert_failure
}

# 2.3
@test "2.3  - Allow Docker to make changes to iptables" {
  result=$(get_docker_effective_command_line_args '--iptables')
  run grep "false" <<< "$result"
  assert_failure
}

# 2.4
@test "2.4  - Do not use insecure registries" {
  result=$(get_docker_effective_command_line_args '--insecure-registry')
  run grep "insecure-registry" <<< "$result"
  assert_failure
}

# 2.5
@test "2.5  - Do not use the aufs storage driver" {
  result=$(docker info 2>/dev/null)
  run grep -e "^Storage Driver:\s*aufs\s*$" <<< "$result"
  assert_failure
}

# 2.6
@test "2.6  - Configure TLS authentication for Docker daemon" {
  result=$(get_docker_cumulative_command_line_args '-H')
  run grep -vE '(unix|fd)://' <<< "$result"
  if [ $status -eq 0 ]; then
    result=$(get_command_line_args docker)
    run $(grep "tlsverify" <<< "$result" | grep "tlskey")
    assert_success
  fi
}

# 2.7
@test "2.7 - Set default ulimit as appropriate" {
  result=$(get_docker_effective_command_line_args '--default-ulimit')
  run grep "default-ulimit" <<< "$result"
  assert_success
}

# 2.8
@test "2.8  - Enable user namespace support" {
  result=$(get_docker_effective_command_line_args '--userns-remap')
  run grep "userns-remap" <<< "$result"
  assert_success
}

# 2.9
@test "2.9  - Confirm default cgroup usage" {
  result=$(get_docker_effective_command_line_args '--cgroup-parent')
  run grep "cgroup-parent" <<< "$result"
  if [ $status -eq 0 ]; then
    assert_output_contains "docker"
  fi
}

# 2.10
@test "2.10 - Do not change base device size until needed" {
  result=$(get_docker_effective_command_line_args '--storage-opt')
  run grep "dm.basesize" <<< "$result"
  assert_failure
}

# 2.11
@test "2.11 - Use authorization plugin" {
  result=$(get_docker_effective_command_line_args '--authorization-plugin')
  run grep "authorization-plugin" <<< "$result"
  assert_success
}

# 2.12
@test "2.12 - Configure centralized and remote logging" {
  result=$(get_docker_effective_command_line_args '--log-driver')
  run grep "log-driver" <<< "$result"
  assert_success
}

# 2.13
@test "2.13 - Disable operations on legacy registry (v1)" {
  result=$(get_docker_effective_command_line_args '--disable-legacy-registry')
  run grep "disable-legacy-registry" <<< "$result"
  assert_success
}
