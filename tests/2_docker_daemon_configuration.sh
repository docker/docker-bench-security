#!/bin/bash

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
  local desc="Run the Docker daemon as a non-root user, if possible (Manual)"
  local remediation="Follow the current Dockerdocumentation on how to install the Docker daemon as a non-root user."
  local remediationImpact="There are multiple prerequisites depending on which distribution that is in use, and also known limitations regarding networking and resource limitation. Running in rootless mode also changes the location of any configuration files in use, including all containers using the daemon."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_2_2() {
  local id="2.2"
  local desc="Ensure network traffic is restricted between containers on the default bridge (Scored)"
  local remediation="Edit the Docker daemon configuration file to ensure that inter-container communication is disabled: icc: false."
  local remediationImpact="Inter-container communication is disabled on the default network bridge. If any communication between containers on the same host is desired, it needs to be explicitly defined using container linking or custom networks."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_effective_command_line_args '--icc' | grep false >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  if get_docker_configuration_file_args 'icc' | grep "false" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_2_3() {
  local id="2.3"
  local desc="Ensure the logging level is set to 'info' (Scored)"
  local remediation="Ensure that the Docker daemon configuration file has the following configuration included log-level: info. Alternatively, run the Docker daemon as following: dockerd --log-level=info"
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'log-level' >/dev/null 2>&1; then
    if get_docker_configuration_file_args 'log-level' | grep info >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    if [ -z "$(get_docker_configuration_file_args 'log-level')" ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  if get_docker_effective_command_line_args '-l'; then
    if get_docker_effective_command_line_args '-l' | grep "info" >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_4() {
  local id="2.4"
  local desc="Ensure Docker is allowed to make changes to iptables (Scored)"
  local remediation="Do not run the Docker daemon with --iptables=false option."
  local remediationImpact="The Docker daemon service requires iptables rules to be enabled before it starts."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_effective_command_line_args '--iptables' | grep "false" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  if get_docker_configuration_file_args 'iptables' | grep "false" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_5() {
  local id="2.5"
  local desc="Ensure insecure registries are not used (Scored)"
  local remediation="You should ensure that no insecure registries are in use."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_effective_command_line_args '--insecure-registry' | grep "insecure-registry" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  if ! [ -z "$(get_docker_configuration_file_args 'insecure-registries')" ]; then
    if get_docker_configuration_file_args 'insecure-registries' | grep '\[]' >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_6() {
  local id="2.6"
  local desc="Ensure aufs storage driver is not used (Scored)"
  local remediation="Do not start Docker daemon as using dockerd --storage-driver aufs option."
  local remediationImpact="aufs is the only storage driver that allows containers to share executable and shared  library memory. Its use should be reviewed in line with your organization's security policy."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "^\sStorage Driver:\s*aufs\s*$" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_7() {
  local id="2.7"
  local desc="Ensure TLS authentication for Docker daemon is configured (Scored)"
  local remediation="Follow the steps mentioned in the Docker documentation or other references. By default, TLS authentication is not configured."
  local remediationImpact="You would need to manage and guard certificates and keys for the Docker daemon and Docker clients."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if [ $(get_docker_configuration_file_args 'tcp://') ] || \
    [ $(get_docker_cumulative_command_line_args '-H' | grep -vE '(unix|fd)://') >/dev/null 2>&1 ]; then
    if [ $(get_docker_configuration_file_args '"tlsverify":' | grep 'true') ] || \
        [ $(get_docker_cumulative_command_line_args '--tlsverify' | grep 'tlsverify') >/dev/null 2>&1 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    if [ $(get_docker_configuration_file_args '"tls":' | grep 'true') ] || \
        [ $(get_docker_cumulative_command_line_args '--tls' | grep 'tls$') >/dev/null 2>&1 ]; then
      warn -s "$check"
      warn "     * Docker daemon currently listening on TCP with TLS, but no verification"
      logcheckresult "WARN" "Docker daemon currently listening on TCP with TLS, but no verification"
      return
    fi
    warn -s "$check"
    warn "     * Docker daemon currently listening on TCP without TLS"
    logcheckresult "WARN" "Docker daemon currently listening on TCP without TLS"
    return
  fi
  info -c "$check"
  info "     * Docker daemon not listening on TCP"
  logcheckresult "INFO" "Docker daemon not listening on TCP"
}

check_2_8() {
  local id="2.8"
  local desc="Ensure the default ulimit is configured appropriately (Manual)"
  local remediation="Run Docker in daemon mode and pass --default-ulimit as option with respective ulimits as appropriate in your environment and in line with your security policy. Example: dockerd --default-ulimit nproc=1024:2048 --default-ulimit nofile=100:200"
  local remediationImpact="If ulimits are set incorrectly this could cause issues with system resources, possibly causing a denial of service condition."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'default-ulimit' | grep -v '{}' >/dev/null 2>&1; then
    pass -c "$check"
    logcheckresult "PASS"
    return
  fi
  if get_docker_effective_command_line_args '--default-ulimit' | grep "default-ulimit" >/dev/null 2>&1; then
    pass -c "$check"
    logcheckresult "PASS"
    return
  fi
  info -c "$check"
  info "     * Default ulimit doesn't appear to be set"
  logcheckresult "INFO" "Default ulimit doesn't appear to be set"
}

check_2_9() {
  local id="2.9"
  local desc="Enable user namespace support (Scored)"
  local remediation="Please consult the Docker documentation for various ways in which this can be configured depending upon your requirements. The high-level steps are: Ensure that the files /etc/subuid and /etc/subgid exist. Start the docker daemon with --userns-remap flag."
  local remediationImpact="User namespace remapping is incompatible with a number of Docker features and also currently breaks some of its functionalities."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'userns-remap' | grep -v '""'; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  if get_docker_effective_command_line_args '--userns-remap' | grep "userns-remap" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_2_10() {
  local id="2.10"
  local desc="Ensure the default cgroup usage has been confirmed (Scored)"
  local remediation="The default setting is in line with good security practice and can be left in situ."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'cgroup-parent' | grep -v ''; then
    warn -s "$check"
    info "     * Confirm cgroup usage"
    logcheckresult "WARN" "Confirm cgroup usage"
    return
  fi
  if get_docker_effective_command_line_args '--cgroup-parent' | grep "cgroup-parent" >/dev/null 2>&1; then
    warn -s "$check"
    info "     * Confirm cgroup usage"
    logcheckresult "WARN" "Confirm cgroup usage"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_11() {
  local id="2.11"
  local desc="Ensure base device size is not changed until needed (Scored)"
  local remediation="Do not set --storage-opt dm.basesize until needed."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'storage-opts' | grep "dm.basesize" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  if get_docker_effective_command_line_args '--storage-opt' | grep "dm.basesize" >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_12() {
  local id="2.12"
  local desc="Ensure that authorization for Docker client commands is enabled (Scored)"
  local remediation="Install/Create an authorization plugin. Configure the authorization policy as desired. Start the docker daemon using command dockerd --authorization-plugin=<PLUGIN_ID>"
  local remediationImpact="Each Docker command needs to pass through the authorization plugin mechanism. This may have a performance impact"
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'authorization-plugins' | grep -v '\[]'; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  if get_docker_effective_command_line_args '--authorization-plugin' | grep "authorization-plugin" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_2_13() {
  local id="2.13"
  local desc="Ensure centralized and remote logging is configured (Scored)"
  local remediation="Set up the desired log driver following its documentation. Start the docker daemon using that logging driver. Example: dockerd --log-driver=syslog --log-opt syslog-address=tcp://192.xxx.xxx.xxx"
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info --format '{{ .LoggingDriver }}' | grep 'json-file' >/dev/null 2>&1; then
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check"
  logcheckresult "PASS"
}

check_2_14() {
  local id="2.14"
  local desc="Ensure containers are restricted from acquiring new privileges (Scored)"
  local remediation="You should run the Docker daemon using command: dockerd --no-new-privileges"
  local remediationImpact="no_new_priv prevents LSMs such as SELinux from escalating the privileges of individual containers."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_effective_command_line_args '--no-new-privileges' | grep "no-new-privileges" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  if get_docker_configuration_file_args 'no-new-privileges' | grep true >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_2_15() {
  local id="2.15"
  local desc="Ensure live restore is enabled (Scored)"
  local remediation="Run Docker in daemon mode and pass --live-restore option."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Live Restore Enabled:\s*true\s*" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    pass -s "$check (Incompatible with swarm mode)"
    logcheckresult "PASS"
    return
  fi
  if get_docker_effective_command_line_args '--live-restore' | grep "live-restore" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_2_16() {
  local id="2.16"
  local desc="Ensure Userland Proxy is Disabled (Scored)"
  local remediation="You should run the Docker daemon using command: dockerd --userland-proxy=false"
  local remediationImpact="Some systems with older Linux kernels may not be able to support hairpin NAT and therefore require the userland proxy service. Also, some networking setups can be impacted by the removal of the userland proxy."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if get_docker_configuration_file_args 'userland-proxy' | grep false >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  if get_docker_effective_command_line_args '--userland-proxy=false' 2>/dev/null | grep "userland-proxy=false" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_2_17() {
  local id="2.17"
  local desc="Ensure that a daemon-wide custom seccomp profile is applied if appropriate (Manual)"
  local remediation="By default, Docker's default seccomp profile is applied. If this is adequate for your environment, no action is necessary."
  local remediationImpact="A misconfigured seccomp profile could possibly interrupt your container environment. You should therefore exercise extreme care if you choose to override the default settings."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info --format '{{ .SecurityOptions }}' | grep 'name=seccomp,profile=default' 2>/dev/null 1>&2; then
    pass -c "$check"
    logcheckresult "PASS"
    return
  fi
  info -c "$check"
  logcheckresult "INFO"
}

check_2_18() {
  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,.' | cut -c 1-4)

  local id="2.18"
  local desc="Ensure that experimental features are not implemented in production (Scored)"
  local remediation="You should not pass --experimental as a runtime parameter to the Docker daemon on production systems."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if [ "$docker_version" -le 1903 ]; then
    if docker version -f '{{.Server.Experimental}}' | grep false 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  local desc="$desc (Deprecated)"
  local check="$id - $desc"
  info -c "$desc"
  logcheckresult "INFO"
}

check_2_end() {
  endsectionjson
}
