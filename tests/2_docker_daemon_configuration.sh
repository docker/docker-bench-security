#!/bin/sh

check_2() {
  logit "\n"
  id_2="2"
  desc_2="Docker daemon configuration"
  check_2="$id_2 - $desc_2"
  info "$check_2"
  startsectionjson "$id_2" "$desc_2"
}

# 2.1
check_2_1() {
  id_2_1="2.1"
  desc_2_1="Ensure network traffic is restricted between containers on the default bridge (Scored)"
  check_2_1="$id_2_1  - $desc_2_1"
  starttestjson "$id_2_1" "$desc_2_1"

  totalChecks=$((totalChecks + 1))
  if get_docker_effective_command_line_args '--icc' | grep false >/dev/null 2>&1; then
    pass "$check_2_1"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  elif get_docker_configuration_file_args 'icc' | grep "false" >/dev/null 2>&1; then
    pass "$check_2_1"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_1"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 2.2
check_2_2() {
  id_2_2="2.2"
  desc_2_2="Ensure the logging level is set to 'info' (Scored)"
  check_2_2="$id_2_2  - $desc_2_2"
  starttestjson "$id_2_2" "$desc_2_2"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'log-level' >/dev/null 2>&1; then
    if get_docker_configuration_file_args 'log-level' | grep info >/dev/null 2>&1; then
      pass "$check_2_2"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    elif [ -z "$(get_docker_configuration_file_args 'log-level')" ]; then
      pass "$check_2_2"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_2_2"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  elif get_docker_effective_command_line_args '-l'; then
    if get_docker_effective_command_line_args '-l' | grep "info" >/dev/null 2>&1; then
      pass "$check_2_2"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_2_2"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check_2_2"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 2.3
check_2_3() {
  id_2_3="2.3"
  desc_2_3="Ensure Docker is allowed to make changes to iptables (Scored)"
  check_2_3="$id_2_3  - $desc_2_3"
  starttestjson "$id_2_3" "$desc_2_3"

  totalChecks=$((totalChecks + 1))
  if get_docker_effective_command_line_args '--iptables' | grep "false" >/dev/null 2>&1; then
    warn "$check_2_3"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  elif get_docker_configuration_file_args 'iptables' | grep "false" >/dev/null 2>&1; then
    warn "$check_2_3"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  else
    pass "$check_2_3"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 2.4
check_2_4() {
  id_2_4="2.4"
  desc_2_4="Ensure insecure registries are not used (Scored)"
  check_2_4="$id_2_4  - $desc_2_4"
  starttestjson "$id_2_4" "$desc_2_4"

  totalChecks=$((totalChecks + 1))
  if get_docker_effective_command_line_args '--insecure-registry' | grep "insecure-registry" >/dev/null 2>&1; then
    warn "$check_2_4"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  elif ! [ -z "$(get_docker_configuration_file_args 'insecure-registries')" ]; then
    if get_docker_configuration_file_args 'insecure-registries' | grep '\[]' >/dev/null 2>&1; then
      pass "$check_2_4"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_2_4"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check_2_4"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 2.5
check_2_5() {
  id_2_5="2.5"
  desc_2_5="Ensure aufs storage driver is not used (Scored)"
  check_2_5="$id_2_5  - $desc_2_5"
  starttestjson "$id_2_5" "$desc_2_5"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "^\sStorage Driver:\s*aufs\s*$" >/dev/null 2>&1; then
    warn "$check_2_5"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  else
    pass "$check_2_5"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 2.6
check_2_6() {
  id_2_6="2.6"
  desc_2_6="Ensure TLS authentication for Docker daemon is configured (Scored)"
  check_2_6="$id_2_6  - $desc_2_6"
  starttestjson "$id_2_6" "$desc_2_6"

  totalChecks=$((totalChecks + 1))
  if [ $(get_docker_configuration_file_args 'tcp://') ] || \
    [ $(get_docker_cumulative_command_line_args '-H' | grep -vE '(unix|fd)://') >/dev/null 2>&1 ]; then
    if [ $(get_docker_configuration_file_args '"tlsverify":' | grep 'true') ] || \
        [ $(get_docker_cumulative_command_line_args '--tlsverify' | grep 'tlsverify') >/dev/null 2>&1 ]; then
      pass "$check_2_6"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    elif [ $(get_docker_configuration_file_args '"tls":' | grep 'true') ] || \
        [ $(get_docker_cumulative_command_line_args '--tls' | grep 'tls$') >/dev/null 2>&1 ]; then
      warn "$check_2_6"
      warn "     * Docker daemon currently listening on TCP with TLS, but no verification"
      resulttestjson "WARN" "Docker daemon currently listening on TCP with TLS, but no verification"
      currentScore=$((currentScore - 1))
    else
      warn "$check_2_6"
      warn "     * Docker daemon currently listening on TCP without TLS"
      resulttestjson "WARN" "Docker daemon currently listening on TCP without TLS"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_2_6"
    info "     * Docker daemon not listening on TCP"
    resulttestjson "INFO" "Docker daemon not listening on TCP"
    currentScore=$((currentScore + 0))
  fi
}

# 2.7
check_2_7() {
  id_2_7="2.7"
  desc_2_7="Ensure the default ulimit is configured appropriately (Not Scored)"
  check_2_7="$id_2_7  - $desc_2_7"
  starttestjson "$id_2_7" "$desc_2_7"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'default-ulimit' | grep -v '{}' >/dev/null 2>&1; then
    pass "$check_2_7"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  elif get_docker_effective_command_line_args '--default-ulimit' | grep "default-ulimit" >/dev/null 2>&1; then
    pass "$check_2_7"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    info "$check_2_7"
    info "     * Default ulimit doesn't appear to be set"
    resulttestjson "INFO" "Default ulimit doesn't appear to be set"
    currentScore=$((currentScore + 0))
  fi
}

# 2.8
check_2_8() {
  id_2_8="2.8"
  desc_2_8="Enable user namespace support (Scored)"
  check_2_8="$id_2_8  - $desc_2_8"
  starttestjson "$id_2_8" "$desc_2_8"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'userns-remap' | grep -v '""'; then
    pass "$check_2_8"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  elif get_docker_effective_command_line_args '--userns-remap' | grep "userns-remap" >/dev/null 2>&1; then
    pass "$check_2_8"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_8"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 2.9
check_2_9() {
  id_2_9="2.9"
  desc_2_9="Ensure the default cgroup usage has been confirmed (Scored)"
  check_2_9="$id_2_9  - $desc_2_9"
  starttestjson "$id_2_9" "$desc_2_9"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'cgroup-parent' | grep -v ''; then
    warn "$check_2_9"
    info "     * Confirm cgroup usage"
    resulttestjson "WARN" "Confirm cgroup usage"
    currentScore=$((currentScore + 0))
  elif get_docker_effective_command_line_args '--cgroup-parent' | grep "cgroup-parent" >/dev/null 2>&1; then
    warn "$check_2_9"
    info "     * Confirm cgroup usage"
    resulttestjson "WARN" "Confirm cgroup usage"
    currentScore=$((currentScore + 0))
  else
    pass "$check_2_9"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 2.10
check_2_10() {
  id_2_10="2.10"
  desc_2_10="Ensure base device size is not changed until needed (Scored)"
  check_2_10="$id_2_10  - $desc_2_10"
  starttestjson "$id_2_10" "$desc_2_10"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'storage-opts' | grep "dm.basesize" >/dev/null 2>&1; then
    warn "$check_2_10"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  elif get_docker_effective_command_line_args '--storage-opt' | grep "dm.basesize" >/dev/null 2>&1; then
    warn "$check_2_10"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  else
    pass "$check_2_10"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 2.11
check_2_11() {
  id_2_11="2.11"
  desc_2_11="Ensure that authorization for Docker client commands is enabled (Scored)"
  check_2_11="$id_2_11  - $desc_2_11"
  starttestjson "$id_2_11" "$desc_2_11"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'authorization-plugins' | grep -v '\[]'; then
    pass "$check_2_11"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  elif get_docker_effective_command_line_args '--authorization-plugin' | grep "authorization-plugin" >/dev/null 2>&1; then
    pass "$check_2_11"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_11"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 2.12
check_2_12() {
  id_2_12="2.12"
  desc_2_12="Ensure centralized and remote logging is configured (Scored)"
  check_2_12="$id_2_12  - $desc_2_12"
  starttestjson "$id_2_12" "$desc_2_12"

  totalChecks=$((totalChecks + 1))
  if docker info --format '{{ .LoggingDriver }}' | grep 'json-file' >/dev/null 2>&1; then
    warn "$check_2_12"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  else
    pass "$check_2_12"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 2.13
check_2_13() {
  id_2_13="2.13"
  desc_2_13="Ensure live restore is enabled (Scored)"
  check_2_13="$id_2_13  - $desc_2_13"
  starttestjson "$id_2_13" "$desc_2_13"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Live Restore Enabled:\s*true\s*" >/dev/null 2>&1; then
    pass "$check_2_13"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
      pass "$check_2_13 (Incompatible with swarm mode)"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    elif get_docker_effective_command_line_args '--live-restore' | grep "live-restore" >/dev/null 2>&1; then
      pass "$check_2_13"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_2_13"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  fi
}

# 2.14
check_2_14() {
  id_2_14="2.14"
  desc_2_14="Ensure Userland Proxy is Disabled (Scored)"
  check_2_14="$id_2_14  - $desc_2_14"
  starttestjson "$id_2_14" "$desc_2_14"

  totalChecks=$((totalChecks + 1))
  if get_docker_configuration_file_args 'userland-proxy' | grep false >/dev/null 2>&1; then
    pass "$check_2_14"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  elif get_docker_effective_command_line_args '--userland-proxy=false' 2>/dev/null | grep "userland-proxy=false" >/dev/null 2>&1; then
    pass "$check_2_14"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_14"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 2.15
check_2_15() {
  id_2_15="2.15"
  desc_2_15="Ensure that a daemon-wide custom seccomp profile is applied if appropriate (Not Scored)"
  check_2_15="$id_2_15  - $desc_2_15"
  starttestjson "$id_2_15" "$desc_2_15"

  totalChecks=$((totalChecks + 1))
  if docker info --format '{{ .SecurityOptions }}' | grep 'name=seccomp,profile=default' 2>/dev/null 1>&2; then
    pass "$check_2_15"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    info "$check_2_15"
    resulttestjson "INFO"
    currentScore=$((currentScore + 0))
  fi
}

# 2.16
check_2_16() {
  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,.' | cut -c 1-4)

  id_2_16="2.16"
  desc_2_16="Ensure that experimental features are not implemented in production (Scored)"
  check_2_16="$id_2_16  - $desc_2_16"
  starttestjson "$id_2_16" "$desc_2_16"

  totalChecks=$((totalChecks + 1))
  if [ "$docker_version" -le 1903 ]; then
    if docker version -f '{{.Server.Experimental}}' | grep false 2>/dev/null 1>&2; then
      pass "$check_2_16"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_2_16"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    desc_2_16="$desc_2_16 (Deprecated)"
    check_2_16="$id_2_16  - $desc_2_16"
    info "$desc_2_16"
    resulttestjson "INFO"
  fi
}

# 2.17
check_2_17() {
  id_2_17="2.17"
  desc_2_17="Ensure containers are restricted from acquiring new privileges (Scored)"
  check_2_17="$id_2_17  - $desc_2_17"
  starttestjson "$id_2_17" "$desc_2_17"

  totalChecks=$((totalChecks + 1))
  if get_docker_effective_command_line_args '--no-new-privileges' | grep "no-new-privileges" >/dev/null 2>&1; then
    pass "$check_2_17"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  elif get_docker_configuration_file_args 'no-new-privileges' | grep true >/dev/null 2>&1; then
    pass "$check_2_17"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_2_17"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

check_2_end() {
  endsectionjson
}
