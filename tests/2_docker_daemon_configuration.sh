#!/bin/sh

logit "\n"
info "2 - Docker Daemon Configuration"

# 2.1
check_2_1="2.1  - Restrict network traffic between containers"
if get_docker_effective_command_line_args '--icc' | grep "false" >/dev/null 2>&1; then
  pass "$check_2_1"
else
  warn "$check_2_1"
fi

# 2.2
check_2_2="2.2  - Set the logging level"
if get_docker_effective_command_line_args '-l' >/dev/null 2>&1; then
  if get_docker_effective_command_line_args '-l' | grep "info" >/dev/null 2>&1; then
    pass "$check_2_2"
  else
    warn "$check_2_2"
  fi
else
  pass "$check_2_2"
fi

# 2.3
check_2_3="2.3  - Allow Docker to make changes to iptables"
if get_docker_effective_command_line_args '--iptables' | grep "false" >/dev/null 2>&1; then
  warn "$check_2_3"
else
  pass "$check_2_3"
fi

# 2.4
check_2_4="2.4  - Do not use insecure registries"
if get_docker_effective_command_line_args '--insecure-registry' | grep "insecure-registry" >/dev/null 2>&1; then
  warn "$check_2_4"
else
  pass "$check_2_4"
fi

# 2.5
check_2_5="2.5  - Do not use the aufs storage driver"
if docker info 2>/dev/null | grep -e "^Storage Driver:\s*aufs\s*$" >/dev/null 2>&1; then
  warn "$check_2_5"
else
  pass "$check_2_5"
fi

# 2.6
check_2_6="2.6  - Configure TLS authentication for Docker daemon"
if get_docker_cumulative_command_line_args '-H' | grep -vE '(unix|fd)://' >/dev/null 2>&1; then
  if get_docker_cumulative_command_line_args '--tlskey' | grep 'tlskey=' >/dev/null 2>&1; then
    if get_docker_cumulative_command_line_args '--tlsverify' | grep 'tlsverify' >/dev/null 2>&1; then
      pass "$check_2_6"
    else
      warn "$check_2_6"
      warn "     * Docker daemon currently listening on TCP with TLS, but no verification"
    fi
  else
    warn "$check_2_6"
    warn "     * Docker daemon currently listening on TCP without TLS"
  fi
else
  info "$check_2_6"
  info "     * Docker daemon not listening on TCP"
fi


# 2.7
check_2_7="2.7  - Set default ulimit as appropriate"
if get_docker_effective_command_line_args '--default-ulimit' | grep "default-ulimit" >/dev/null 2>&1; then
  pass "$check_2_7"
else
  info "$check_2_7"
  info "     * Default ulimit doesn't appear to be set"
fi

# 2.8
check_2_8="2.8  - Enable user namespace support"
if get_docker_effective_command_line_args '--userns-remap' | grep "userns-remap" >/dev/null 2>&1; then
  pass "$check_2_8"
else
  warn "$check_2_8"
fi

# 2.9
check_2_9="2.9  - Confirm default cgroup usage"
if get_docker_effective_command_line_args '--cgroup-parent' | grep "cgroup-parent" >/dev/null 2>&1; then
  warn "$check_2_9"
  info "     * Confirm cgroup usage"
else
  pass "$check_2_9"
fi

# 2.10
check_2_10="2.10 - Do not change base device size until needed"
if get_docker_effective_command_line_args '--storage-opt' | grep "dm.basesize" >/dev/null 2>&1; then
  warn "$check_2_10"
else
  pass "$check_2_10"
fi

# 2.11
check_2_11="2.11 - Use authorization plugin"
if get_docker_effective_command_line_args '--authorization-plugin' | grep "authorization-plugin" >/dev/null 2>&1; then
  pass "$check_2_11"
else
  warn "$check_2_11"
fi

# 2.12
check_2_12="2.12 - Configure centralized and remote logging"
if get_docker_effective_command_line_args '--log-driver' | grep "log-driver" >/dev/null 2>&1; then
  pass "$check_2_12"
else
  warn "$check_2_12"
fi

# 2.13
check_2_13="2.13 - Disable operations on legacy registry (v1)"
if get_docker_effective_command_line_args '--disable-legacy-registry' | grep "disable-legacy-registry" >/dev/null 2>&1; then
  pass "$check_2_13"
else
  warn "$check_2_13"
fi

# 2.14
check_2_14="2.14 - Enable live restore"
if docker info 2>/dev/null | grep -e "Live Restore Enabled:\s*true\s*" >/dev/null 2>&1; then
  pass "$check_2_14"
else
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    pass "$check_2_14 (Incompatible with swarm mode)"
  else
    warn "$check_2_14"
  fi
fi

# 2.15
check_2_15="2.15 - Do not enable swarm mode, if not needed"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
  pass "$check_2_15"
else
  warn "$check_2_15"
fi

# 2.16
check_2_16="2.16 - Control the number of manager nodes in a swarm"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
  managernodes=$(docker node ls | grep -c "Leader")
  if [ "$managernodes" -le 1 ]; then
    pass "$check_2_16"
  else
    warn "$check_2_16"
  fi
else
  pass "$check_2_16 (Swarm mode not enabled)"
fi

# 2.17
check_2_17="2.17 - Bind swarm services to a specific host interface"
netstat -lt | grep -e '\[::]:2377' -e '*:2377' -e '0.0.0.0:2377' >/dev/null 2>&1
if [ $? -eq 1 ]; then
  pass "$check_2_17"
else
  warn "$check_2_17"
fi

# 2.18
check_2_18="2.18 - Disable Userland Proxy"
if get_docker_effective_command_line_args '--userland-proxy=false' 2>/dev/null | grep "userland-proxy=false" >/dev/null 2>&1; then
  pass "$check_2_18"
else
  warn "$check_2_18"
fi

# 2.19
check_2_19="2.19 - Encrypt data exchanged between containers on different nodes on the overlay network"
if docker network ls --filter driver=overlay --quiet | \
  xargs docker network inspect --format '{{.Name}} {{ .Options }}' 2>/dev/null | \
    grep -v 'encrypted:' 2>/dev/null 1>&2; then
  warn "$check_2_19"
  for encnet in $(docker network ls --filter driver=overlay --quiet); do
    if docker network inspect --format '{{.Name}} {{ .Options }}' "$encnet" | \
       grep -v 'encrypted:' 2>/dev/null 1>&2; then
      warn "     * Unencrypted overlay network: $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
    fi
  done
else
  pass "$check_2_19"
fi

# 2.20
check_2_20="2.20 - Apply a daemon-wide custom seccomp profile, if needed"
if docker info --format '{{ .SecurityOptions }}' | grep 'name=seccomp,profile=default' 2>/dev/null 1>&2; then
  pass "$check_2_20"
else
  info "$check_2_20"
fi

# 2.21
check_2_21="2.21 - Avoid experimental features in production"
if docker info 2>/dev/null | grep -e "^Live Restore Enabled:\s*false\s*$" >/dev/null 2>&1; then
  pass "$check_2_21"
else
  warn "$check_2_21"
fi

# 2.22
check_2_22="2.22 - Use Docker's secret management commands for managing secrets in a Swarm cluster"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
  if [ "$(docker secret ls -q | wc -l)" -ge 1 ]; then
    pass "$check_2_22"
  else
    info "$check_2_22"
  fi
else
  pass "$check_2_22 (Swarm mode not enabled)"
fi

# 2.23
check_2_23="2.23 - Run swarm manager in auto-lock mode"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
  if ! docker swarm unlock-key 2>/dev/null | grep 'SWMKEY' 2>/dev/null 1>&2; then
    warn "$check_2_23"
  else
    pass "$check_2_23"
  fi
else
  pass "$check_2_23 (Swarm mode not enabled)"
fi

# 2.24
check_2_24="2.24 - Rotate swarm manager auto-lock key periodically"
info "$check_2_24"
