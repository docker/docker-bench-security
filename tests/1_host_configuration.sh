#!/bin/sh

logit ""
info "1 - Host Configuration"
auditrules="/etc/audit/audit.rules"

# 1.1
check_1_1="1.1  - Ensure a separate partition for containers has been created"
if grep /var/lib/docker /etc/fstab >/dev/null 2>&1; then
  pass "$check_1_1"
else
  warn "$check_1_1"
fi

# 1.2
check_1_2="1.2  - Ensure the container host has been Hardened"
note "$check_1_2"

# 1.3
check_1_3="1.3  - Ensure Docker is up to date"
docker_version=$(docker version | grep -i -A1 '^server' | grep -i 'version:' \
  | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
docker_current_version="$(date --date="$(date +%y-%m-1) -1 month" +%y.%m.0)"
do_version_check "$docker_current_version" "$docker_version"
if [ $? -eq 11 ]; then
  info "$check_1_3"
  info "     * Using $docker_version, verify is it up to date as deemed necessary"
  info "     * Your operating system vendor may provide support and security maintenance for Docker"
else
  pass "$check_1_3"
  info "     * Using $docker_version which is current"
  info "     * Check with your operating system vendor for support and security maintenance for Docker"
fi

# 1.4
check_1_4="1.4  - Ensure only trusted users are allowed to control Docker daemon"
docker_users=$(getent group docker)
info "$check_1_4"
for u in $docker_users; do
  info "     * $u"
done

# 1.5
check_1_5="1.5  - Ensure auditing is configured for the Docker daemon"
file="/usr/bin/docker "
if command -v auditctl >/dev/null 2>&1; then
  if auditctl -l | grep "$file" >/dev/null 2>&1; then
    pass "$check_1_5"
  else
    warn "$check_1_5"
  fi
elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
  pass "$check_1_5"
else
  warn "$check_1_5"
fi

# 1.6
check_1_6="1.6  - Ensure auditing is configured for Docker files and directories - /var/lib/docker"
directory="/var/lib/docker"
if [ -d "$directory" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep $directory >/dev/null 2>&1; then
      pass "$check_1_6"
    else
      warn "$check_1_6"
    fi
  elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check_1_6"
  else
    warn "$check_1_6"
  fi
else
  info "$check_1_6"
  info "     * Directory not found"
fi

# 1.7
check_1_7="1.7  - Ensure auditing is configured for Docker files and directories - /etc/docker"
directory="/etc/docker"
if [ -d "$directory" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep $directory >/dev/null 2>&1; then
      pass "$check_1_7"
    else
      warn "$check_1_7"
    fi
  elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_7"
  else
      warn "$check_1_7"
  fi
else
  info "$check_1_7"
  info "     * Directory not found"
fi

# 1.8
check_1_8="1.8  - Ensure auditing is configured for Docker files and directories - docker.service"
file="$(get_systemd_service_file docker.service)"
if [ -f "$file" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep "$file" >/dev/null 2>&1; then
      pass "$check_1_8"
    else
      warn "$check_1_8"
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_8"
  else
      warn "$check_1_8"
  fi
else
  info "$check_1_8"
  info "     * File not found"
fi

# 1.9
check_1_9="1.9  - Ensure auditing is configured for Docker files and directories - docker.socket"
file="$(get_systemd_service_file docker.socket)"
if [ -e "$file" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep "$file" >/dev/null 2>&1; then
      pass "$check_1_9"
    else
      warn "$check_1_9"
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check_1_9"
  else
    warn "$check_1_9"
  fi
else
  info "$check_1_9"
  info "     * File not found"
fi

# 1.10
check_1_10="1.10 - Ensure auditing is configured for Docker files and directories - /etc/default/docker"
file="/etc/default/docker"
if [ -f "$file" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep $file >/dev/null 2>&1; then
      pass "$check_1_10"
    else
      warn "$check_1_10"
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check_1_10"
  else
    warn "$check_1_10"
  fi
else
  info "$check_1_10"
  info "     * File not found"
fi

# 1.11
check_1_11="1.11 - Ensure auditing is configured for Docker files and directories - /etc/docker/daemon.json"
file="/etc/docker/daemon.json"
if [ -f "$file" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep $file >/dev/null 2>&1; then
      pass "$check_1_11"
    else
      warn "$check_1_11"
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check_1_11"
  else
    warn "$check_1_11"
  fi
else
  info "$check_1_11"
  info "     * File not found"
fi

# 1.12
check_1_12="1.12 - Ensure auditing is configured for Docker files and directories - /usr/bin/docker-containerd"
file="/usr/bin/docker-containerd"
if [ -f "$file" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep $file >/dev/null 2>&1; then
      pass "$check_1_12"
    else
      warn "$check_1_12"
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check_1_12"
  else
    warn "$check_1_12"
  fi
else
  info "$check_1_12"
  info "     * File not found"
fi

# 1.13
check_1_13="1.13 - Ensure auditing is configured for Docker files and directories - /usr/bin/docker-runc"
file="/usr/bin/docker-runc"
if [ -f "$file" ]; then
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep $file >/dev/null 2>&1; then
      pass "$check_1_13"
    else
      warn "$check_1_13"
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check_1_13"
  else
    warn "$check_1_13"
  fi
else
  info "$check_1_13"
  info "     * File not found"
fi
