#!/bin/sh

logit ""
info "1 - Host Configuration"

# 1.1
check_1_1="1.1  - Create a separate partition for containers"
grep /var/lib/docker /etc/fstab >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "$check_1_1"
else
  warn "$check_1_1"
fi

# 1.2
check_1_2="1.2  - Use an updated Linux Kernel"
kernel_version=$(uname -r | cut -d "-" -f 1)
do_version_check 3.10 "$kernel_version"
if [ $? -eq 11 ]; then
  warn "$check_1_2"
else
  pass "$check_1_2"
fi

# 1.5
check_1_5="1.5  - Remove all non-essential services from the host - Network"
# Check for listening network services.
listening_services=$(netstat -na | grep -v tcp6 | grep -v unix | grep -c LISTEN)
if [ "$listening_services" -eq 0 ]; then
  warn "1.5  - Failed to get listening services for check: $check_1_5"
else
  if [ "$listening_services" -gt 5 ]; then
    warn "$check_1_5"
    warn "     * Host listening on: $listening_services ports"
  else
    pass "$check_1_5"
  fi
fi

# 1.6
check_1_6="1.6  - Keep Docker up to date"
docker_version=$(docker version | grep -i -A1 '^server' | grep -i 'version:' \
  | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
docker_current_version="1.9.1"
docker_current_date="2015-11-09"
do_version_check "$docker_current_version" "$docker_version"
if [ $? -eq 11 ]; then
  warn "$check_1_6"
  warn "      * Using $docker_version, when $docker_current_version is current as of $docker_current_date"
  info "      * Your operating system vendor may provide support and security maintenance for docker"
else
  pass "$check_1_6"
  info "      * Using $docker_version which is current as of $docker_current_date"
  info "      * Check with your operating system vendor for support and security maintenance for docker"
fi

# 1.7
check_1_7="1.7  - Only allow trusted users to control Docker daemon"
docker_users=$(getent group docker)
info "$check_1_7"
for u in $docker_users; do
  info "     * $u"
done

# 1.8
check_1_8="1.8  - Audit docker daemon"
command -v auditctl >/dev/null 2>&1
if [ $? -eq 0 ]; then
  auditctl -l | grep /usr/bin/docker >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    pass "$check_1_8"
  else
    warn "$check_1_8"
  fi
else
  warn "1.8  - Failed to inspect: auditctl command not found."
fi

# 1.9
check_1_9="1.9  - Audit Docker files and directories - /var/lib/docker"
directory="/var/lib/docker"
if [ -d "$directory" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $directory >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_9"
    else
      warn "$check_1_9"
    fi
  else
    warn "1.9  - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_9"
  info "     * Directory not found"
fi

# 1.10
check_1_10="1.10 - Audit Docker files and directories - /etc/docker"
directory="/etc/docker"
if [ -d "$directory" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $directory >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_10"
    else
      warn "$check_1_10"
    fi
  else
    warn "1.10 - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_10"
  info "     * Directory not found"
fi

# 1.11
check_1_11="1.11 - Audit Docker files and directories - docker-registry.service"
file="$(get_systemd_service_file docker-registry.service)"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_11"
    else
      warn "$check_1_11"
    fi
  else
    warn "1.11 - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_11"
  info "     * File not found"
fi

# 1.12
check_1_12="1.12 - Audit Docker files and directories - docker.service"
file="$(get_systemd_service_file docker.service)"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_12"
    else
      warn "$check_1_12"
    fi
  else
    warn "1.12 - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_12"
  info "     * File not found"
fi

# 1.13
check_1_13="1.13 - Audit Docker files and directories - /var/run/docker.sock"
file="/var/run/docker.sock"
if [ -e "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_13"
    else
      warn "$check_1_13"
    fi
  else
    warn "1.13 - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_13"
  info "     * File not found"
fi

# 1.14
check_1_14="1.14 - Audit Docker files and directories - /etc/sysconfig/docker"
file="/etc/sysconfig/docker"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_14"
    else
      warn "$check_1_14"
    fi
  else
    warn "1.14 - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_14"
  info "     * File not found"
fi

# 1.15
check_1_15="1.15 - Audit Docker files and directories - /etc/sysconfig/docker-network"
file="/etc/sysconfig/docker-network"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_15"
    else
      warn "$check_1_15"
    fi
  else
    warn "1.15 - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_15"
  info "     * File not found"
fi

# 1.16
check_1_16="1.16 - Audit Docker files and directories - /etc/sysconfig/docker-registry"
file="/etc/sysconfig/docker-registry"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_16"
    else
      warn "$check_1_16"
    fi
  else
    warn "1.16 - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_16"
  info "     * File not found"
fi

# 1.17
check_1_17="1.17 - Audit Docker files and directories - /etc/sysconfig/docker-storage"
file="/etc/sysconfig/docker-storage"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_17"
    else
      warn "$check_1_17"
    fi
  else
    warn "1.17 - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_17"
  info "     * File not found"
fi

# 1.18
check_1_18="1.18 - Audit Docker files and directories - /etc/default/docker"
file="/etc/default/docker"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      pass "$check_1_18"
    else
      warn "$check_1_18"
    fi
  else
    warn "1.18 - Failed to inspect: auditctl command not found."
  fi
else
  info "$check_1_18"
  info "     * File not found"
fi
