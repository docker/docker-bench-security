#!/bin/sh

check_1() {
  logit ""
  local id="1"
  local desc="Host Configuration"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_1_1() {
  local id="1.1"
  local desc="General Configuration"
  local check="$id - $desc"
  info "$check"
}

# 1.1.1
check_1_1_1() {
  local id="1.1.1"
  local desc="Ensure the container host has been Hardened (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  note "$check"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 1.1.2
check_1_1_2() {
  local id="1.1.2"
  local desc="Ensure that the version of Docker is up to date (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
  docker_current_version="$(date +%y.%m.0 -d @$(( $(date +%s) - 2592000)))"
  do_version_check "$docker_current_version" "$docker_version"
  if [ $? -eq 11 ]; then
    info "$check"
    info "       * Using $docker_version, verify is it up to date as deemed necessary"
    info "       * Your operating system vendor may provide support and security maintenance for Docker"
    resulttestjson "INFO" "Using $docker_version"
    currentScore=$((currentScore + 0))
  else
    pass "$check"
    info "       * Using $docker_version which is current"
    info "       * Check with your operating system vendor for support and security maintenance for Docker"
    resulttestjson "PASS" "Using $docker_version"
    currentScore=$((currentScore + 0))
  fi
}

check_1_2() {
  local id="1.2"
  local desc="Linux Hosts Specific Configuration"
  local check="$id - $desc"
  info "$check"
}

# 1.2.1
check_1_2_1() {
  local id="1.2.1"
  local desc="Ensure a separate partition for containers has been created (Scored)"
  local remediation="For new installations, you should create a separate partition for the \'/var/lib/docker\' mount point. For systems that have already been installed, you should use the Logical Volume Manager (LVM) within Linux to create a new partition."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  docker_root_dir=$(docker info -f '{{ .DockerRootDir }}')
  if docker info | grep -q userns ; then
    docker_root_dir=$(readlink -f "$docker_root_dir/..")
  fi

  if mountpoint -q -- "$docker_root_dir" >/dev/null 2>&1; then
    pass "$check"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 1.2.2
check_1_2_2() {
  local id="1.2.2"
  local desc="Ensure only trusted users are allowed to control Docker daemon (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if command -v getent >/dev/null 2>&1; then
    docker_users=$(getent group docker)
  else
    docker_users=$(grep 'docker' /etc/group)
  fi
  info "$check"
  for u in $docker_users; do
    info "       * $u"
  done
  resulttestjson "INFO" "users" "$docker_users"
  currentScore=$((currentScore + 0))
}

# 1.2.3
check_1_2_3() {
  local id="1.2.3"
  local desc="Ensure auditing is configured for the Docker daemon (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w /usr/bin/dockerd -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/usr/bin/dockerd"
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep "$file" >/dev/null 2>&1; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 1.2.4
check_1_2_4() {
  local id="1.2.4"
  local desc="Ensure auditing is configured for Docker files and directories - /var/lib/docker (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w /var/lib/docker -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  directory="/var/lib/docker"
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass "$check"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check"
        saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "       * Directory not found"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.5
check_1_2_5() {
  local id="1.2.5"
  local desc="Ensure auditing is configured for Docker files and directories - /etc/docker (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w /etc/docker -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass "$check"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check"
        saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "       * Directory not found"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "INFO" "Directory not found"
    currentScore=$((currentScore + 0))
fi
}

# 1.2.6
check_1_2_6() {
  local id="1.2.6"
  local desc="Ensure auditing is configured for Docker files and directories - docker.service (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w $(systemctl show -p FragmentPath docker.service | sed 's/.*=//') -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass "$check"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check"
        saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "       * File not found"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.7
check_1_2_7() {
  local id="1.2.7"
  local desc="Ensure auditing is configured for Docker files and directories - docker.socket (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w $(systemctl show -p FragmentPath docker.socket | sed 's/.*=//') -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="$(get_service_file docker.socket)"
  if [ -e "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass "$check"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check"
        saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "       * File not found"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.8
check_1_2_8() {
  local id="1.2.8"
  local desc="Ensure auditing is configured for Docker files and directories - /etc/default/docker (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w /etc/default/docker -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check"
        saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "       * File not found"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.9
check_1_2_9() {
  local id="1.2.9"
  local desc="Ensure auditing is configured for Docker files and directories - /etc/sysconfig/docker (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w /etc/sysconfig/docker -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check"
        saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "       * File not found"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.10
check_1_2_10() {
  local id="1.2.10"
  local desc="Ensure auditing is configured for Docker files and directories - /etc/docker/daemon.json (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w /etc/docker/daemon.json -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check"
        saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "        * File not found"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.11
check_1_2_11() {
  local id="1.2.11"
  local desc="Ensure auditing is configured for Docker files and directories - /usr/bin/containerd (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w /usr/bin/containerd -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/usr/bin/containerd"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check"
        saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "        * File not found"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.12
check_1_2_12() {
  local id="1.2.12"
  local desc="Ensure auditing is configured for Docker files and directories - /usr/sbin/runc (Scored)"
  local remediation="Install and configure auditd using command \'sudo apt-get install auditd\'. Add \'-w /usr/sbin/runc -k docker\' to the \'/etc/audit/rules.d/audit.rules\' file. Then restart the audit daemon using command \'service auditd restart\'."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  file="/usr/sbin/runc"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check"
        saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check"
    info "        * File not found"
    saveRemediation --id "${id}" --rem "${remediation}" --imp "${remediationImpact}"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

check_1_end() {
  endsectionjson
}
