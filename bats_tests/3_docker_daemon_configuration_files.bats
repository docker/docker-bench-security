#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "$BATS_TEST_DIRNAME/../helper_lib.sh"

# 3.1
@test "3.1  - Verify that docker.service file ownership is set to root:root" {
  file="$(get_systemd_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g "$file")" -ne 00 ]; then
      fail "Wrong ownership for $file"
    fi
  fi
}

# 3.2
@test "3.2  - Verify that docker.service file permissions are set to 644" {
  file="$(get_systemd_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a "$file")" -ne 644 ]; then
      fail "Wrong permissions for $file"
    fi
  fi
}

# 3.3
@test "3.3  - Verify that docker.socket file ownership is set to root:root" {
  file="$(get_systemd_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g "$file")" -ne 00 ]; then
      fail "Wrong ownership for $file"
    fi
  fi
}

# 3.4
@test "3.4  - Verify that docker.socket file permissions are set to 644" {
  file="$(get_systemd_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a "$file")" -ne 644 ]; then
      fail "Wrong permissions for $file"
    fi
  fi
}

# 3.5
@test "3.5  - Verify that /etc/docker directory ownership is set to root:root" {
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %u%g $directory)" -ne 00 ]; then
      fail "Wrong ownership for $directory"
    fi
  fi
}

# 3.6
@test "3.6  - Verify that /etc/docker directory permissions are set to 755 or 700" {
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %a $directory)" -ne 755 ] && [ "$(stat -c %a $directory)" -ne 700 ]; then
      fail "Wrong permissions for $directory : $(stat -c %a $directory)"
    fi
  fi
}

# 3.7
@test "3.7  - Verify that registry certificate file ownership is set to root:root" {
  directory="/etc/docker/certs.d/"
  if [ -d "$directory" ]; then
    fail=0
    owners=$(ls -lL $directory | grep ".crt" | awk '{print $3, $4}')
    for p in $owners; do
      printf "%s" "$p" | grep "root" >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        fail=1
      fi
    done
    if [ $fail -eq 1 ]; then
      fail "Wrong ownership for $directory"
    fi
  fi
}

# 3.8
@test "3.8  - Verify that registry certificate file permissions are set to 444" {
  directory="/etc/docker/certs.d/"
  if [ -d "$directory" ]; then
    fail=0
    perms=$(ls -lL $directory | grep ".crt" | awk '{print $1}')
    for p in $perms; do
      if [ "$p" != "-r--r--r--." ] && [ "$p" = "-r--------." ]; then
        fail=1
      fi
    done
    if [ $fail -eq 1 ]; then
      fail "Wrong permissions for $directory"
    fi
  fi
}

# 3.9
@test "3.9  - Verify that TLS CA certificate file ownership is set to root:root" {
  tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %u%g "$tlscacert")" -ne 00 ]; then
      fail "Wrong ownership for $tlscacert : $(stat -c %u%g "$tlscacert")"
    fi
  fi
}

# 3.10
@test "3.10 - Verify that TLS CA certificate file permissions are set to 444" {
  tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -f "$tlscacert" ]; then
    perms=$(ls -ld "$tlscacert" | awk '{print $1}')
    if [ "$perms" != "-r--r--r--" ]; then
      fail "Wrong permissions for $tlscacert"
    fi
  fi
}

# 3.11
@test "3.11 - Verify that Docker server certificate file ownership is set to root:root" {
  tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %u%g "$tlscert")" -ne 00 ]; then
      fail "Wrong ownership for $tlscert : $(stat -c %u%g "$tlscert")"
    fi
  fi
}

# 3.12
@test "3.12 - Verify that Docker server certificate file permissions are set to 444" {
  tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -f "$tlscert" ]; then
    perms=$(ls -ld "$tlscert" | awk '{print $1}')
    if [ "$perms" != "-r--r--r--" ]; then
      fail "Wrong permissions for $tlscert"
    fi
  fi
}

# 3.13
@test "3.13 - Verify that Docker server key file ownership is set to root:root" {
  tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %u%g "$tlskey")" -ne 00 ]; then
      fail "Wrong ownership for $tlskey : $(stat -c %u%g "$tlskey")"
    fi
  fi
}

# 3.14
@test "3.14 - Verify that Docker server key file permissions are set to 400" {
  tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  if [ -f "$tlskey" ]; then
    perms=$(ls -ld "$tlskey" | awk '{print $1}')
    if [ "$perms" != "-r--------" ]; then
      fail "Wrong permissions for $tlskey"
    fi
  fi
}

# 3.15
@test "3.15 - Verify that Docker socket file ownership is set to root:docker" {
  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %U:%G $file)" != 'root:docker' ]; then
      fail "Wrong ownership for $file"
    fi
  fi
}

# 3.16
@test "3.16 - Verify that Docker socket file permissions are set to 660" {
  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %a $file)" -ne 660 ]; then
      fail "Wrong permissions for $file"
    fi
  fi
}

# 3.17
@test "3.17 - Verify that daemon.json file ownership is set to root:root" {
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" != 'root:root' ]; then
      fail "Wrong ownership for $file"
    fi
  fi
}

# 3.18
@test "3.18 - Verify that daemon.json file permissions are set to 644" {
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -ne 644 ]; then
      fail "Wrong permissions for $file"
    fi
  fi
}

# 3.19
@test "3.19 - Verify that /etc/default/docker file ownership is set to root:root" {
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" != 'root:root' ]; then
      fail "Wrong ownership for $file"
    fi
  fi
}

# 3.20
@test "3.20 - Verify that /etc/default/docker file permissions are set to 644" {
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -ne 644 ]; then
      fail "Wrong permissions for $file"
    fi
  fi
}
