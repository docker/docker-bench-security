#!/bin/sh

check_3() {
  logit "\n"
  id_3="3"
  desc_3="Docker daemon configuration files"
  check_3="$id_3 - $desc_3"
  info "$check_3"
  startsectionjson "$id_3" "$desc_3"
}

# 3.1
check_3_1() {
  id_3_1="3.1"
  desc_3_1="Ensure that the docker.service file ownership is set to root:root (Scored)"
  check_3_1="$id_3_1  - $desc_3_1"
  starttestjson "$id_3_1" "$desc_3_1"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g $file)" -eq 00 ]; then
      pass "$check_3_1"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_1"
      warn "     * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_1"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.2
check_3_2() {
  id_3_2="3.2"
  desc_3_2="Ensure that docker.service file permissions are appropriately set (Scored)"
  check_3_2="$id_3_2  - $desc_3_2"
  starttestjson "$id_3_2" "$desc_3_2"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check_3_2"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_2"
      warn "     * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_2"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.3
check_3_3() {
  id_3_3="3.3"
  desc_3_3="Ensure that docker.socket file ownership is set to root:root (Scored)"
  check_3_3="$id_3_3  - $desc_3_3"
  starttestjson "$id_3_3" "$desc_3_3"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %u%g $file)" -eq 00 ]; then
      pass "$check_3_3"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_3"
      warn "     * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_3"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.4
check_3_4() {
  id_3_4="3.4"
  desc_3_4="Ensure that docker.socket file permissions are set to 644 or more restrictive (Scored)"
  check_3_4="$id_3_4  - $desc_3_4"
  starttestjson "$id_3_4" "$desc_3_4"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.socket)"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check_3_4"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_4"
      warn "     * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_4"
    info "     * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.5
check_3_5() {
  id_3_5="3.5"
  desc_3_5="Ensure that the /etc/docker directory ownership is set to root:root (Scored)"
  check_3_5="$id_3_5  - $desc_3_5"
  starttestjson "$id_3_5" "$desc_3_5"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %u%g $directory)" -eq 00 ]; then
      pass "$check_3_5"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_5"
      warn "     * Wrong ownership for $directory"
      resulttestjson "WARN" "Wrong ownership for $directory"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_5"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.6
check_3_6() {
  id_3_6="3.6"
  desc_3_6="Ensure that /etc/docker directory permissions are set to 755 or more restrictively (Scored)"
  check_3_6="$id_3_6  - $desc_3_6"
  starttestjson "$id_3_6" "$desc_3_6"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if [ "$(stat -c %a $directory)" -le 755 ]; then
      pass "$check_3_6"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_6"
      warn "     * Wrong permissions for $directory"
      resulttestjson "WARN" "Wrong permissions for $directory"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_6"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.7
check_3_7() {
  id_3_7="3.7"
  desc_3_7="Ensure that registry certificate file ownership is set to root:root (Scored)"
  check_3_7="$id_3_7  - $desc_3_7"
  starttestjson "$id_3_7" "$desc_3_7"

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
      warn "$check_3_7"
      warn "     * Wrong ownership for $directory"
      resulttestjson "WARN" "Wrong ownership for $directory"
      currentScore=$((currentScore - 1))
    else
      pass "$check_3_7"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    fi
  else
    info "$check_3_7"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.8
check_3_8() {
  id_3_8="3.8"
  desc_3_8="Ensure that registry certificate file permissions are set to 444 or more restrictively (Scored)"
  check_3_8="$id_3_8  - $desc_3_8"
  starttestjson "$id_3_8" "$desc_3_8"

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
      warn "$check_3_8"
      warn "     * Wrong permissions for $directory"
      resulttestjson "WARN" "Wrong permissions for $directory"
      currentScore=$((currentScore - 1))
    else
      pass "$check_3_8"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    fi
  else
    info "$check_3_8"
    info "     * Directory not found"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.9
check_3_9() {
  id_3_9="3.9"
  desc_3_9="Ensure that TLS CA certificate file ownership is set to root:root (Scored)"
  check_3_9="$id_3_9  - $desc_3_9"
  starttestjson "$id_3_9" "$desc_3_9"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_docker_configuration_file_args 'tlscacert')
  else
    tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %u%g "$tlscacert")" -eq 00 ]; then
      pass "$check_3_9"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_9"
      warn "     * Wrong ownership for $tlscacert"
      resulttestjson "WARN" "Wrong ownership for $tlscacert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_9"
    info "     * No TLS CA certificate found"
    resulttestjson "INFO" "No TLS CA certificate found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.10
check_3_10() {
  id_3_10="3.10"
  desc_3_10="Ensure that TLS CA certificate file permissions are set to 444 or more restrictively (Scored)"
  check_3_10="$id_3_10  - $desc_3_10"
  starttestjson "$id_3_10" "$desc_3_10"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscacert')" ]; then
    tlscacert=$(get_docker_configuration_file_args 'tlscacert')
  else
    tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscacert" ]; then
    if [ "$(stat -c %a $tlscacert)" -le 444 ]; then
      pass "$check_3_10"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_10"
      warn "      * Wrong permissions for $tlscacert"
      resulttestjson "WARN" "Wrong permissions for $tlscacert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_10"
    info "      * No TLS CA certificate found"
    resulttestjson "INFO" "No TLS CA certificate found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.11
check_3_11() {
  id_3_11="3.11"
  desc_3_11="Ensure that Docker server certificate file ownership is set to root:root (Scored)"
  check_3_11="$id_3_11  - $desc_3_11"
  starttestjson "$id_3_11" "$desc_3_11"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_docker_configuration_file_args 'tlscert')
  else
    tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %u%g "$tlscert")" -eq 00 ]; then
      pass "$check_3_11"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_11"
      warn "      * Wrong ownership for $tlscert"
      resulttestjson "WARN" "Wrong ownership for $tlscert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_11"
    info "      * No TLS Server certificate found"
    resulttestjson "INFO" "No TLS Server certificate found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.12
check_3_12() {
  id_3_12="3.12"
  desc_3_12="Ensure that the Docker server certificate file permissions are set to 444 or more restrictively (Scored)"
  check_3_12="$id_3_12  - $desc_3_12"
  starttestjson "$id_3_12" "$desc_3_12"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlscert')" ]; then
    tlscert=$(get_docker_configuration_file_args 'tlscert')
  else
    tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlscert" ]; then
    if [ "$(stat -c %a $tlscert)" -le 444 ]; then
      pass "$check_3_12"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_12"
      warn "      * Wrong permissions for $tlscert"
      resulttestjson "WARN" "Wrong permissions for $tlscert"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_12"
    info "      * No TLS Server certificate found"
    resulttestjson "INFO" "No TLS Server certificate found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.13
check_3_13() {
  id_3_13="3.13"
  desc_3_13="Ensure that the Docker server certificate key file ownership is set to root:root (Scored)"
  check_3_13="$id_3_13  - $desc_3_13"
  starttestjson "$id_3_13" "$desc_3_13"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_docker_configuration_file_args 'tlskey')
  else
    tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %u%g "$tlskey")" -eq 00 ]; then
      pass "$check_3_13"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_13"
      warn "      * Wrong ownership for $tlskey"
      resulttestjson "WARN" "Wrong ownership for $tlskey"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_13"
    info "      * No TLS Key found"
    resulttestjson "INFO" "No TLS Key found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.14
check_3_14() {
  id_3_14="3.14"
  desc_3_14="Ensure that the Docker server certificate key file permissions are set to 400 (Scored)"
  check_3_14="$id_3_14  - $desc_3_14"
  starttestjson "$id_3_14" "$desc_3_14"

  totalChecks=$((totalChecks + 1))
  if [ -n "$(get_docker_configuration_file_args 'tlskey')" ]; then
    tlskey=$(get_docker_configuration_file_args 'tlskey')
  else
    tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
  fi
  if [ -f "$tlskey" ]; then
    if [ "$(stat -c %a $tlskey)" -eq 400 ]; then
      pass "$check_3_14"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_14"
      warn "      * Wrong permissions for $tlskey"
      resulttestjson "WARN" "Wrong permissions for $tlskey"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_14"
    info "      * No TLS Key found"
    resulttestjson "INFO" "No TLS Key found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.15
check_3_15() {
  id_3_15="3.15"
  desc_3_15="Ensure that the Docker socket file ownership is set to root:docker (Scored)"
  check_3_15="$id_3_15  - $desc_3_15"
  starttestjson "$id_3_15" "$desc_3_15"

  totalChecks=$((totalChecks + 1))
  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:docker' ]; then
      pass "$check_3_15"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_15"
      warn "      * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_15"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.16
check_3_16() {
  id_3_16="3.16"
  desc_3_16="Ensure that the Docker socket file permissions are set to 660 or more restrictively (Scored)"
  check_3_16="$id_3_16  - $desc_3_16"
  starttestjson "$id_3_16" "$desc_3_16"

  totalChecks=$((totalChecks + 1))
  file="/var/run/docker.sock"
  if [ -S "$file" ]; then
    if [ "$(stat -c %a $file)" -le 660 ]; then
      pass "$check_3_16"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_16"
      warn "      * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_16"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.17
check_3_17() {
  id_3_17="3.17"
  desc_3_17="Ensure that the daemon.json file ownership is set to root:root (Scored)"
  check_3_17="$id_3_17  - $desc_3_17"
  starttestjson "$id_3_17" "$desc_3_17"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass "$check_3_17"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_17"
      warn "      * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_17"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.18
check_3_18() {
  id_3_18="3.18"
  desc_3_18="Ensure that daemon.json file permissions are set to 644 or more restrictive (Scored)"
  check_3_18="$id_3_18  - $desc_3_18"
  starttestjson "$id_3_18" "$desc_3_18"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check_3_18"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_18"
      warn "      * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_18"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.19
check_3_19() {
  id_3_19="3.19"
  desc_3_19="Ensure that the /etc/default/docker file ownership is set to root:root (Scored)"
  check_3_19="$id_3_19  - $desc_3_19"
  starttestjson "$id_3_19" "$desc_3_19"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass "$check_3_19"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_19"
      warn "      * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_19"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.20
check_3_20() {
  id_3_20="3.20"
  desc_3_20="Ensure that the /etc/sysconfig/docker file ownership is set to root:root (Scored)"
  check_3_20="$id_3_20  - $desc_3_20"
  starttestjson "$id_3_20" "$desc_3_20"

  totalChecks=$((totalChecks + 1))
  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
      pass "$check_3_20"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_20"
      warn "      * Wrong ownership for $file"
      resulttestjson "WARN" "Wrong ownership for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_20"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.21
check_3_21() {
  id_3_21="3.21"
  desc_3_21="Ensure that the /etc/sysconfig/docker file permissions are set to 644 or more restrictively (Scored)"
  check_3_21="$id_3_21  - $desc_3_21"
  starttestjson "$id_3_21" "$desc_3_21"

  totalChecks=$((totalChecks + 1))
  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check_3_21"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_21"
      warn "      * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_21"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 3.22
check_3_22() {
  id_3_22="3.22"
  desc_3_22="Ensure that the /etc/default/docker file permissions are set to 644 or more restrictively (Scored)"
  check_3_22="$id_3_22  - $desc_3_22"
  starttestjson "$id_3_22" "$desc_3_22"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if [ "$(stat -c %a $file)" -le 644 ]; then
      pass "$check_3_22"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_3_22"
      warn "      * Wrong permissions for $file"
      resulttestjson "WARN" "Wrong permissions for $file"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_3_22"
    info "      * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

check_3_end() {
  endsectionjson
}
