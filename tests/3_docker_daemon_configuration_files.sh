#!/bin/sh

check_3() {
  logit ""
  local id="3"
  local desc="Docker daemon configuration files"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_3_1() {
  local id="3.1"
  local desc="Ensure that the docker.service file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g $file)" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "     * Wrong ownership for $file"
      logcheckresult "WARN" "Wrong ownership for $file"
    fi
  else
    info -c "$check"
    info "     * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_2() {
  local id="3.2"
  local desc="Ensure that docker.service file permissions are appropriately set (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "     * Wrong permissions for $file"
      logcheckresult "WARN" "Wrong permissions for $file"
    fi
  else
    info -c "$check"
    info "     * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_3() {
  local id="3.3"
  local desc="Ensure that docker.socket file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="$(get_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g $file)" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "     * Wrong ownership for $file"
      logcheckresult "WARN" "Wrong ownership for $file"
    fi
  else
    info -c "$check"
    info "     * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_4() {
  local id="3.4"
  local desc="Ensure that docker.socket file permissions are set to 644 or more restrictive (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="$(get_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "     * Wrong permissions for $file"
      logcheckresult "WARN" "Wrong permissions for $file"
    fi
  else
    info -c "$check"
    info "     * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_5() {
  local id="3.5"
  local desc="Ensure that the /etc/docker directory ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %u%g $directory)" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "     * Wrong ownership for $directory"
      logcheckresult "WARN" "Wrong ownership for $directory"
    fi
  else
    info -c "$check"
    info "     * Directory not found"
    logcheckresult "INFO" "Directory not found"
  fi
}

check_3_6() {
  local id="3.6"
  local desc="Ensure that /etc/docker directory permissions are set to 755 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %a $directory)" -le 755 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "     * Wrong permissions for $directory"
      logcheckresult "WARN" "Wrong permissions for $directory"
    fi
  else
    info -c "$check"
    info "     * Directory not found"
    logcheckresult "INFO" "Directory not found"
  fi
}

check_3_7() {
  local id="3.7"
  local desc="Ensure that registry certificate file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

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
      warn -s "$check"
      warn "     * Wrong ownership for $directory"
      logcheckresult "WARN" "Wrong ownership for $directory"
    else
      pass -s "$check"
      logcheckresult "PASS"
    fi
  else
    info -c "$check"
    info "     * Directory not found"
    logcheckresult "INFO" "Directory not found"
  fi
}

check_3_8() {
  local id="3.8"
  local desc="Ensure that registry certificate file permissions are set to 444 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

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
      warn -s "$check"
      warn "     * Wrong permissions for $directory"
      logcheckresult "WARN" "Wrong permissions for $directory"
    else
      pass -s "$check"
      logcheckresult "PASS"
    fi
  else
    info -c "$check"
    info "     * Directory not found"
    logcheckresult "INFO" "Directory not found"
  fi
}

check_3_9() {
  local id="3.9"
  local desc="Ensure that TLS CA certificate file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ -n "$(get_docker_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_docker_configuration_file_args 'tlscacert')
  else
    tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %u%g "$tlscacert")" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "     * Wrong ownership for $tlscacert"
      logcheckresult "WARN" "Wrong ownership for $tlscacert"
    fi
  else
    info -c "$check"
    info "     * No TLS CA certificate found"
    logcheckresult "INFO" "No TLS CA certificate found"
  fi
}

check_3_10() {
  local id="3.10"
  local desc="Ensure that TLS CA certificate file permissions are set to 444 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ -n "$(get_docker_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_docker_configuration_file_args 'tlscacert')
  else
    tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %a $tlscacert)" -le 444 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong permissions for $tlscacert"
      logcheckresult "WARN" "Wrong permissions for $tlscacert"
    fi
  else
    info -c "$check"
    info "      * No TLS CA certificate found"
    logcheckresult "INFO" "No TLS CA certificate found"
  fi
}

check_3_11() {
  local id="3.11"
  local desc="Ensure that Docker server certificate file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ -n "$(get_docker_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_docker_configuration_file_args 'tlscert')
  else
    tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %u%g "$tlscert")" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong ownership for $tlscert"
      logcheckresult "WARN" "Wrong ownership for $tlscert"
    fi
  else
    info -c "$check"
    info "      * No TLS Server certificate found"
    logcheckresult "INFO" "No TLS Server certificate found"
  fi
}

check_3_12() {
  local id="3.12"
  local desc="Ensure that the Docker server certificate file permissions are set to 444 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ -n "$(get_docker_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_docker_configuration_file_args 'tlscert')
  else
    tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %a $tlscert)" -le 444 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong permissions for $tlscert"
      logcheckresult "WARN" "Wrong permissions for $tlscert"
    fi
  else
    info -c "$check"
    info "      * No TLS Server certificate found"
    logcheckresult "INFO" "No TLS Server certificate found"
  fi
}

check_3_13() {
  local id="3.13"
  local desc="Ensure that the Docker server certificate key file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ -n "$(get_docker_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_docker_configuration_file_args 'tlskey')
  else
    tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %u%g "$tlskey")" -eq 00 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong ownership for $tlskey"
      logcheckresult "WARN" "Wrong ownership for $tlskey"
    fi
  else
    info -c "$check"
    info "      * No TLS Key found"
    logcheckresult "INFO" "No TLS Key found"
  fi
}

check_3_14() {
  local id="3.14"
  local desc="Ensure that the Docker server certificate key file permissions are set to 400 (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ -n "$(get_docker_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_docker_configuration_file_args 'tlskey')
  else
    tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %a $tlskey)" -eq 400 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong permissions for $tlskey"
      logcheckresult "WARN" "Wrong permissions for $tlskey"
    fi
  else
    info -c "$check"
    info "      * No TLS Key found"
    logcheckresult "INFO" "No TLS Key found"
  fi
}

check_3_15() {
  local id="3.15"
  local desc="Ensure that the Docker socket file ownership is set to root:docker (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:docker' ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong ownership for $file"
      logcheckresult "WARN" "Wrong ownership for $file"
    fi
  else
    info -c "$check"
    info "      * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_16() {
  local id="3.16"
  local desc="Ensure that the Docker socket file permissions are set to 660 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %a $file)" -le 660 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong permissions for $file"
      logcheckresult "WARN" "Wrong permissions for $file"
    fi
  else
    info -c "$check"
    info "      * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_17() {
  local id="3.17"
  local desc="Ensure that the daemon.json file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong ownership for $file"
      logcheckresult "WARN" "Wrong ownership for $file"
    fi
  else
    info -c "$check"
    info "      * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_18() {
  local id="3.18"
  local desc="Ensure that daemon.json file permissions are set to 644 or more restrictive (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong permissions for $file"
      logcheckresult "WARN" "Wrong permissions for $file"
    fi
  else
    info -c "$check"
    info "      * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_19() {
  local id="3.19"
  local desc="Ensure that the /etc/default/docker file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong ownership for $file"
      logcheckresult "WARN" "Wrong ownership for $file"
    fi
  else
    info -c "$check"
    info "      * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_20() {
  local id="3.20"
  local desc="Ensure that the /etc/sysconfig/docker file ownership is set to root:root (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong ownership for $file"
      logcheckresult "WARN" "Wrong ownership for $file"
    fi
  else
    info -c "$check"
    info "      * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_21() {
  local id="3.21"
  local desc="Ensure that the /etc/sysconfig/docker file permissions are set to 644 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong permissions for $file"
      logcheckresult "WARN" "Wrong permissions for $file"
    fi
  else
    info -c "$check"
    info "      * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_22() {
  local id="3.22"
  local desc="Ensure that the /etc/default/docker file permissions are set to 644 or more restrictively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      warn "      * Wrong permissions for $file"
      logcheckresult "WARN" "Wrong permissions for $file"
    fi
  else
    info -c "$check"
    info "      * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_3_end() {
  endsectionjson
}
