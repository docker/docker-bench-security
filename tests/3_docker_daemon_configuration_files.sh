#!/bin/sh

check_3() {
  logit "\n"
  local id="3"
  local desc="Docker daemon configuration files"
  local check="$id - $desc"
  info "$check"
  startsectionjson "$id" "$desc"
}

# 3.1
check_3_1() {
  local id="3.1"
  local desc="Ensure that the docker.service file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g $file)" -eq 00 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "     * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.2
check_3_2() {
  local id="3.2"
  local desc="Ensure that docker.service file permissions are appropriately set (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "     * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.3
check_3_3() {
  local id="3.3"
  local desc="Ensure that docker.socket file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g $file)" -eq 00 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "     * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.4
check_3_4() {
  local id="3.4"
  local desc="Ensure that docker.socket file permissions are set to 644 or more restrictive (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "     * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.5
check_3_5() {
  local id="3.5"
  local desc="Ensure that the /etc/docker directory ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %u%g $directory)" -eq 00 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "     * Wrong ownership for $directory"
      resulttestjson "WARN" "Wrong ownership for $directory"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.6
check_3_6() {
  local id="3.6"
  local desc="Ensure that /etc/docker directory permissions are set to 755 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %a $directory)" -le 755 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "     * Wrong permissions for $directory"
      resulttestjson "WARN" "Wrong permissions for $directory"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.7
check_3_7() {
  local id="3.7"
  local desc="Ensure that registry certificate file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker/certs.d/"
  if [ -d "$directory" ]; then
    fail=0
    owners=$(find "$directory" -type f -name '*.crt')
    for p in $owners; do
      if [ "$(stat -c %u $p)" -ne 0 ]; then
        fail=1
      fi
    done
    if [ $fail -eq 1 ]; then
      warn "$check"
      warn "     * Wrong ownership for $directory"
      resulttestjson "WARN" "Wrong ownership for $directory"
      currentScore=$((currentScore - 1))
    else
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    fi
  else
    info "$check"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.8
check_3_8() {
  local id="3.8"
  local desc="Ensure that registry certificate file permissions are set to 444 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker/certs.d/"
  if [ -d "$directory" ]; then
    fail=0
    perms=$(find "$directory" -type f -name '*.crt')
    for p in $perms; do
      if [ "$(stat -c %a $p)" -gt 444 ]; then
        fail=1
      fi
    done
    if [ $fail -eq 1 ]; then
      warn "$check"
      warn "     * Wrong permissions for $directory"
      resulttestjson "WARN" "Wrong permissions for $directory"
      currentScore=$((currentScore - 1))
    else
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    fi
  else
    info "$check"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.9
check_3_9() {
  local id="3.9"
  local desc="Ensure that TLS CA certificate file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_docker_configuration_file_args 'tlscacert')
  else
    tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %u%g "$tlscacert")" -eq 00 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "     * Wrong ownership for $tlscacert"
      resulttestjson "WARN" "Wrong ownership for $tlscacert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "     * No TLS CA certificate found"
    resulttestjson "INFO" "No TLS CA certificate found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.10
check_3_10() {
  local id="3.10"
  local desc="Ensure that TLS CA certificate file permissions are set to 444 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_docker_configuration_file_args 'tlscacert')
  else
    tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %a $tlscacert)" -le 444 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong permissions for $tlscacert"
      resulttestjson "WARN" "Wrong permissions for $tlscacert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * No TLS CA certificate found"
    resulttestjson "INFO" "No TLS CA certificate found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.11
check_3_11() {
  local id="3.11"
  local desc="Ensure that Docker server certificate file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_docker_configuration_file_args 'tlscert')
  else
    tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %u%g "$tlscert")" -eq 00 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong ownership for $tlscert"
      resulttestjson "WARN" "Wrong ownership for $tlscert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * No TLS Server certificate found"
    resulttestjson "INFO" "No TLS Server certificate found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.12
check_3_12() {
  local id="3.12"
  local desc="Ensure that the Docker server certificate file permissions are set to 444 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_docker_configuration_file_args 'tlscert')
  else
    tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %a $tlscert)" -le 444 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong permissions for $tlscert"
      resulttestjson "WARN" "Wrong permissions for $tlscert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * No TLS Server certificate found"
    resulttestjson "INFO" "No TLS Server certificate found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.13
check_3_13() {
  local id="3.13"
  local desc="Ensure that the Docker server certificate key file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_docker_configuration_file_args 'tlskey')
  else
    tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %u%g "$tlskey")" -eq 00 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong ownership for $tlskey"
      resulttestjson "WARN" "Wrong ownership for $tlskey"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * No TLS Key found"
    resulttestjson "INFO" "No TLS Key found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.14
check_3_14() {
  local id="3.14"
  local desc="Ensure that the Docker server certificate key file permissions are set to 400 (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_docker_configuration_file_args 'tlskey')
  else
    tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %a $tlskey)" -eq 400 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong permissions for $tlskey"
      resulttestjson "WARN" "Wrong permissions for $tlskey"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * No TLS Key found"
    resulttestjson "INFO" "No TLS Key found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.15
check_3_15() {
  local id="3.15"
  local desc="Ensure that the Docker socket file ownership is set to root:docker (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:docker' ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.16
check_3_16() {
  local id="3.16"
  local desc="Ensure that the Docker socket file permissions are set to 660 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %a $file)" -le 660 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.17
check_3_17() {
  local id="3.17"
  local desc="Ensure that the daemon.json file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.18
check_3_18() {
  local id="3.18"
  local desc="Ensure that daemon.json file permissions are set to 644 or more restrictive (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.19
check_3_19() {
  local id="3.19"
  local desc="Ensure that the /etc/default/docker file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.20
check_3_20() {
  local id="3.20"
  local desc="Ensure that the /etc/sysconfig/docker file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.21
check_3_21() {
  local id="3.21"
  local desc="Ensure that the /etc/sysconfig/docker file permissions are set to 644 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.22
check_3_22() {
  local id="3.22"
  local desc="Ensure that the /etc/default/docker file permissions are set to 644 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      warn "      * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

check_3_end() {
  endsectionjson
}
