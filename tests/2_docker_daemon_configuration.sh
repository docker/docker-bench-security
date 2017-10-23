#!/bin/sh

logit "\n"
info "2 - Docker daemon configuration"

# 2.1
check_2_1="2.1  - Ensure network traffic is restricted between containers on the default bridge"
if get_docker_effective_command_line_args '--icc' | grep false >/dev/null 2>&1; then
  pass "$check_2_1"
  logjson "2.1" "PASS"
elif get_docker_configuration_file_args 'icc' | grep "false" >/dev/null 2>&1; then
  pass "$check_2_1"
  logjson "2.1" "PASS"
else
  warn "$check_2_1"
  logjson "2.1" "WARN"
fi

# 2.2
check_2_2="2.2  - Ensure the logging level is set to 'info'"
if get_docker_configuration_file_args 'log-level' >/dev/null 2>&1; then
  if get_docker_configuration_file_args 'log-level' | grep info >/dev/null 2>&1; then
    pass "$check_2_2"
    logjson "2.2" "PASS"
  elif [ -z "$(get_docker_configuration_file_args 'log-level')" ]; then
    pass "$check_2_2"
    logjson "2.2" "PASS"
  else
    warn "$check_2_2"
    logjson "2.2" "WARN"
  fi
elif get_docker_effective_command_line_args '-l'; then
  if get_docker_effective_command_line_args '-l' | grep "info" >/dev/null 2>&1; then
    pass "$check_2_2"
    logjson "2.2" "PASS"
  else
    warn "$check_2_2"
    logjson "2.2" "WARN"
  fi
else
  pass "$check_2_2"
  logjson "2.2" "PASS"
fi

# 2.3
check_2_3="2.3  - Ensure Docker is allowed to make changes to iptables"
if get_docker_effective_command_line_args '--iptables' | grep "false" >/dev/null 2>&1; then
  warn "$check_2_3"
  logjson "2.3" "WARN"
elif get_docker_configuration_file_args 'iptables' | grep "false" >/dev/null 2>&1; then
  warn "$check_2_3"
  logjson "2.3" "WARN"
else
  pass "$check_2_3"
  logjson "2.3" "PASS"
fi

# 2.4
check_2_4="2.4  - Ensure insecure registries are not used"
if get_docker_effective_command_line_args '--insecure-registry' | grep "insecure-registry" >/dev/null 2>&1; then
  warn "$check_2_4"
  logjson "2.4" "WARN"
elif ! [ -z "$(get_docker_configuration_file_args 'insecure-registries')" ]; then
  if get_docker_configuration_file_args 'insecure-registries' | grep '\[]' >/dev/null 2>&1; then
    pass "$check_2_4"
    logjson "2.4" "PASS"
  else
    warn "$check_2_4"
    logjson "2.4" "WARN"
  fi
else
  pass "$check_2_4"
  logjson "2.4" "PASS"
fi

# 2.5
check_2_5="2.5  - Ensure aufs storage driver is not used"
if docker info 2>/dev/null | grep -e "^Storage Driver:\s*aufs\s*$" >/dev/null 2>&1; then
  warn "$check_2_5"
  logjson "2.5" "WARN"
else
  pass "$check_2_5"
  logjson "2.5" "PASS"
fi

# 2.6
check_2_6="2.6  - Ensure TLS authentication for Docker daemon is configured"
if grep -i 'tcp://' "$CONFIG_FILE" 2>/dev/null 1>&2; then
  if [ $(get_docker_configuration_file_args '"tls":' | grep 'true') ] || \
    [ $(get_docker_configuration_file_args '"tlsverify' | grep 'true') ] ; then
    if get_docker_configuration_file_args 'tlskey' | grep -v '""' >/dev/null 2>&1; then
      if get_docker_configuration_file_args 'tlsverify' | grep 'true' >/dev/null 2>&1; then
        pass "$check_2_6"
        logjson "2.6" "PASS"
      else
        warn "$check_2_6"
        warn "     * Docker daemon currently listening on TCP with TLS, but no verification"
        logjson "2.6" "WARN"
      fi
    fi
  else
    warn "$check_2_6"
    warn "     * Docker daemon currently listening on TCP without TLS"
    logjson "2.6" "WARN"
  fi
elif get_docker_cumulative_command_line_args '-H' | grep -vE '(unix|fd)://' >/dev/null 2>&1; then
  if get_docker_cumulative_command_line_args '--tlskey' | grep 'tlskey=' >/dev/null 2>&1; then
    if get_docker_cumulative_command_line_args '--tlsverify' | grep 'tlsverify' >/dev/null 2>&1; then
      pass "$check_2_6"
      logjson "2.6" "PASS"
    else
      warn "$check_2_6"
      warn "     * Docker daemon currently listening on TCP with TLS, but no verification"
      logjson "2.6" "WARN"
    fi
  else
    warn "$check_2_6"
    warn "     * Docker daemon currently listening on TCP without TLS"
    logjson "2.6" "WARN"
  fi
else
  info "$check_2_6"
  info "     * Docker daemon not listening on TCP"
  logjson "2.6" "INFO"
fi


# 2.7
check_2_7="2.7  - Ensure the default ulimit is configured appropriately"
if get_docker_configuration_file_args 'default-ulimit' | grep -v '{}' >/dev/null 2>&1; then
  pass "$check_2_7"
  logjson "2.7" "PASS"
elif get_docker_effective_command_line_args '--default-ulimit' | grep "default-ulimit" >/dev/null 2>&1; then
  pass "$check_2_7"
  logjson "2.7" "PASS"
else
  info "$check_2_7"
  info "     * Default ulimit doesn't appear to be set"
  logjson "2.7" "INFO"
fi

# 2.8
check_2_8="2.8  - Enable user namespace support"
if get_docker_configuration_file_args 'userns-remap' | grep -v '""'; then
  pass "$check_2_8"
  logjson "2.8" "PASS"
elif get_docker_effective_command_line_args '--userns-remap' | grep "userns-remap" >/dev/null 2>&1; then
  pass "$check_2_8"
  logjson "2.8" "PASS"
else
  warn "$check_2_8"
  logjson "2.8" "WARN"
fi

# 2.9
check_2_9="2.9  - Ensure the default cgroup usage has been confirmed"
if get_docker_configuration_file_args 'cgroup-parent' | grep -v '""'; then
  warn "$check_2_9"
  info "     * Confirm cgroup usage"
  logjson "2.9" "INFO"
elif get_docker_effective_command_line_args '--cgroup-parent' | grep "cgroup-parent" >/dev/null 2>&1; then
  warn "$check_2_9"
  info "     * Confirm cgroup usage"
  logjson "2.9" "INFO"
else
  pass "$check_2_9"
  logjson "2.9" "PASS"
fi

# 2.10
check_2_10="2.10 - Ensure base device size is not changed until needed"
if get_docker_configuration_file_args 'storage-opts' | grep "dm.basesize" >/dev/null 2>&1; then
  warn "$check_2_10"
  logjson "2.10" "WARN"
elif get_docker_effective_command_line_args '--storage-opt' | grep "dm.basesize" >/dev/null 2>&1; then
  warn "$check_2_10"
  logjson "2.10" "WARN"
else
  pass "$check_2_10"
  logjson "2.10" "PASS"
fi

# 2.11
check_2_11="2.11 - Ensure that authorization for Docker client commands is enabled"
if get_docker_configuration_file_args 'authorization-plugins' | grep -v '\[]'; then
  pass "$check_2_11"
  logjson "2.11" "PASS"
elif get_docker_effective_command_line_args '--authorization-plugin' | grep "authorization-plugin" >/dev/null 2>&1; then
  pass "$check_2_11"
  logjson "2.11" "PASS"
else
  warn "$check_2_11"
  logjson "2.11" "WARN"
fi

# 2.12
check_2_12="2.12 - Ensure centralized and remote logging is configured"
if docker info --format '{{ .LoggingDriver }}' | grep 'json-file' >/dev/null 2>&1; then
  warn "$check_2_12"
  logjson "2.12" "WARN"
else
  pass "$check_2_12"
  logjson "2.12" "PASS"
fi

# 2.13
check_2_13="2.13 - Ensure operations on legacy registry (v1) are Disabled"
if get_docker_configuration_file_args 'disable-legacy-registry' | grep 'true' >/dev/null 2>&1; then
  pass "$check_2_13"
  logjson "2.13" "PASS"
elif get_docker_effective_command_line_args '--disable-legacy-registry' | grep "disable-legacy-registry" >/dev/null 2>&1; then
  pass "$check_2_13"
  logjson "2.13" "PASS"
else
  warn "$check_2_13"
  logjson "2.13" "WARN"
fi

# 2.14
check_2_14="2.14 - Ensure live restore is Enabled"
if docker info 2>/dev/null | grep -e "Live Restore Enabled:\s*true\s*" >/dev/null 2>&1; then
  pass "$check_2_14"
  logjson "2.14" "PASS"
else
  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    pass "$check_2_14 (Incompatible with swarm mode)"
    logjson "2.14" "PASS"
  elif get_docker_effective_command_line_args '--live-restore' | grep "live-restore" >/dev/null 2>&1; then
    pass "$check_2_14"
    logjson "2.14" "PASS"
  else
    warn "$check_2_14"
    logjson "2.14" "WARN"
  fi
fi

# 2.15
check_2_15="2.15 - Ensure Userland Proxy is Disabled"
if get_docker_configuration_file_args 'userland-proxy' | grep false >/dev/null 2>&1; then
  pass "$check_2_15"
  logjson "2.15" "PASS"
elif get_docker_effective_command_line_args '--userland-proxy=false' 2>/dev/null | grep "userland-proxy=false" >/dev/null 2>&1; then
  pass "$check_2_15"
  logjson "2.15" "PASS"
else
  warn "$check_2_15"
  logjson "2.15" "WARN"
fi

# 2.16
check_2_16="2.16 - Ensure daemon-wide custom seccomp profile is applied, if needed"
if docker info --format '{{ .SecurityOptions }}' | grep 'name=seccomp,profile=default' 2>/dev/null 1>&2; then
  pass "$check_2_16"
  logjson "2.16" "PASS"
else
  info "$check_2_16"
  logjson "2.16" "INFO"
fi

# 2.17
check_2_17="2.17 - Ensure experimental features are avoided in production"
if docker version -f '{{.Server.Experimental}}' | grep false 2>/dev/null 1>&2; then
  pass "$check_2_17"
  logjson "2.17" "PASS"
else
  warn "$check_2_17"
  logjson "2.17" "WARN"
fi

# 2.18
check_2_18="2.18 - Ensure containers are restricted from acquiring new privileges"
if get_docker_effective_command_line_args '--no-new-privileges' >/dev/null 2>&1; then
  pass "$check_2_18"
  logjson "2.18" "PASS"
elif get_docker_configuration_file_args 'no-new-privileges' >/dev/null 2>&1; then
  pass "$check_2_18"
  logjson "2.18" "PASS"
else
  warn "$check_2_18"
  logjson "2.18" "WARN"
fi
