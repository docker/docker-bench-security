#!/bin/sh

check_2() {
  logit ""
  local id="2"
  local desc="Docker daemon configuration"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_2_1() {
  local id="2.1"
  local desc="Ensure network traffic is restricted between containers on the default bridge (Scored)"
  local remediation="Edit the Docker daemon configuration file to ensure that inter-container communication is disabled: icc: false."
  local remediationImpact="Inter-container communication is disabled on the default network bridge. If any communication between containers on the same host is desired, it needs to be explicitly defined using container linking or custom networks."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_effective_command_line_args '--icc' | grep false >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  elif get_docker_configuration_file_args 'icc' | grep "false" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  else
    warn -s "$check"
    logcheckresult "WARN"
  fi
}

check_2_2() {
  local id="2.2"
  local desc="Ensure the logging level is set to 'info' (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'log-level' >/dev/null 2>&1; then
    if get_docker_configuration_file_args 'log-level' | grep info >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
    elif [ -z "$(get_docker_configuration_file_args 'log-level')" ]; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  elif get_docker_effective_command_line_args '-l'; then
    if get_docker_effective_command_line_args '-l' | grep "info" >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    pass -s "$check"
    logcheckresult "PASS"
  fi
}

check_2_3() {
  local id="2.3"
  local desc="Ensure Docker is allowed to make changes to iptables (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_effective_command_line_args '--iptables' | grep "false" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
  elif get_docker_configuration_file_args 'iptables' | grep "false" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
  else
    pass -s "$check"
    logcheckresult "PASS"
  fi
}

check_2_4() {
  local id="2.4"
  local desc="Ensure insecure registries are not used (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_effective_command_line_args '--insecure-registry' | grep "insecure-registry" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
  elif ! [ -z "$(get_docker_configuration_file_args 'insecure-registries')" ]; then
    if get_docker_configuration_file_args 'insecure-registries' | grep '\[]' >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    pass -s "$check"
    logcheckresult "PASS"
  fi
}

check_2_5() {
  local id="2.5"
  local desc="Ensure aufs storage driver is not used (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "^\sStorage Driver:\s*aufs\s*$" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
  else
    pass -s "$check"
    logcheckresult "PASS"
  fi
}

check_2_6() {
  local id="2.6"
  local desc="Ensure TLS authentication for Docker daemon is configured (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ $(get_docker_configuration_file_args 'tcp://') ] || \
    [ $(get_docker_cumulative_command_line_args '-H' | grep -vE '(unix|fd)://') >/dev/null 2>&1 ]; then
    if [ $(get_docker_configuration_file_args '"tlsverify":' | grep 'true') ] || \
        [ $(get_docker_cumulative_command_line_args '--tlsverify' | grep 'tlsverify') >/dev/null 2>&1 ]; then
      pass -s "$check"
      logcheckresult "PASS"
    elif [ $(get_docker_configuration_file_args '"tls":' | grep 'true') ] || \
        [ $(get_docker_cumulative_command_line_args '--tls' | grep 'tls$') >/dev/null 2>&1 ]; then
      warn -s "$check"
      warn "     * Docker daemon currently listening on TCP with TLS, but no verification"
      logcheckresult "WARN" "Docker daemon currently listening on TCP with TLS, but no verification"
    else
      warn -s "$check"
      warn "     * Docker daemon currently listening on TCP without TLS"
      logcheckresult "WARN" "Docker daemon currently listening on TCP without TLS"
    fi
  else
    info -c "$check"
    info "     * Docker daemon not listening on TCP"
    logcheckresult "INFO" "Docker daemon not listening on TCP"
  fi
}

check_2_7() {
  local id="2.7"
  local desc="Ensure the default ulimit is configured appropriately (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'default-ulimit' | grep -v '{}' >/dev/null 2>&1; then
    pass -c "$check"
    logcheckresult "PASS"
  elif get_docker_effective_command_line_args '--default-ulimit' | grep "default-ulimit" >/dev/null 2>&1; then
    pass -c "$check"
    logcheckresult "PASS"
  else
    info -c "$check"
    info "     * Default ulimit doesn't appear to be set"
    logcheckresult "INFO" "Default ulimit doesn't appear to be set"
  fi
}

check_2_8() {
  local id="2.8"
  local desc="Enable user namespace support (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'userns-remap' | grep -v '""'; then
    pass -s "$check"
    logcheckresult "PASS"
  elif get_docker_effective_command_line_args '--userns-remap' | grep "userns-remap" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  else
    warn -s "$check"
    logcheckresult "WARN"
  fi
}

check_2_9() {
  local id="2.9"
  local desc="Ensure the default cgroup usage has been confirmed (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'cgroup-parent' | grep -v ''; then
    warn -s "$check"
    info "     * Confirm cgroup usage"
    logcheckresult "WARN" "Confirm cgroup usage"
  elif get_docker_effective_command_line_args '--cgroup-parent' | grep "cgroup-parent" >/dev/null 2>&1; then
    warn -s "$check"
    info "     * Confirm cgroup usage"
    logcheckresult "WARN" "Confirm cgroup usage"
  else
    pass -s "$check"
    logcheckresult "PASS"
  fi
}

check_2_10() {
  local id="2.10"
  local desc="Ensure base device size is not changed until needed (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'storage-opts' | grep "dm.basesize" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
  elif get_docker_effective_command_line_args '--storage-opt' | grep "dm.basesize" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
  else
    pass -s "$check"
    logcheckresult "PASS"
  fi
}

check_2_11() {
  local id="2.11"
  local desc="Ensure that authorization for Docker client commands is enabled (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'authorization-plugins' | grep -v '\[]'; then
    pass -s "$check"
    logcheckresult "PASS"
  elif get_docker_effective_command_line_args '--authorization-plugin' | grep "authorization-plugin" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  else
    warn -s "$check"
    logcheckresult "WARN"
  fi
}

check_2_12() {
  local id="2.12"
  local desc="Ensure centralized and remote logging is configured (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if docker info --format '{{ .LoggingDriver }}' | grep 'json-file' >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
  else
    pass -s "$check"
    logcheckresult "PASS"
  fi
}

check_2_13() {
  local id="2.13"
  local desc="Ensure live restore is enabled (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Live Restore Enabled:\s*true\s*" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  else
    if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
      pass -s "$check (Incompatible with swarm mode)"
      logcheckresult "PASS"
    elif get_docker_effective_command_line_args '--live-restore' | grep "live-restore" >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  fi
}

check_2_14() {
  local id="2.14"
  local desc="Ensure Userland Proxy is Disabled (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'userland-proxy' | grep false >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  elif get_docker_effective_command_line_args '--userland-proxy=false' 2>/dev/null | grep "userland-proxy=false" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  else
    warn -s "$check"
    logcheckresult "WARN"
  fi
}

check_2_15() {
  local id="2.15"
  local desc="Ensure that a daemon-wide custom seccomp profile is applied if appropriate (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if docker info --format '{{ .SecurityOptions }}' | grep 'name=seccomp,profile=default' 2>/dev/null 1>&2; then
    pass -c "$check"
    logcheckresult "PASS"
  else
    info -c "$check"
    logcheckresult "INFO"
  fi
}

check_2_16() {
  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,.' | cut -c 1-4)

  local id="2.16"
  local desc="Ensure that experimental features are not implemented in production (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ "$docker_version" -le 1903 ]; then
    if docker version -f '{{.Server.Experimental}}' | grep false 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    local desc="$desc (Deprecated)"
    local check="$id  - $desc"
    info -c "$desc"
    logcheckresult "INFO"
  fi
}

check_2_17() {
  local id="2.17"
  local desc="Ensure containers are restricted from acquiring new privileges (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if get_docker_effective_command_line_args '--no-new-privileges' | grep "no-new-privileges" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  elif get_docker_configuration_file_args 'no-new-privileges' | grep true >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  else
    warn -s "$check"
    logcheckresult "WARN"
  fi
}

check_2_end() {
  endsectionjson
}
