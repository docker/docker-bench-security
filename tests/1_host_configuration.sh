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

check_1_1_1() {
  local id="1.1.1"
  local desc="Ensure the container host has been Hardened (Not Scored)"
  local remediation="You may consider various Security Benchmarks for your container host."
  local remediationImpact="None."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_1_1_2() {
  local id="1.1.2"
  local desc="Ensure that the version of Docker is up to date (Not Scored)"
  local remediation="You should monitor versions of Docker releases and make sure your software is updated as required."
  local remediationImpact="You should perform a risk assessment regarding Docker version updates and review how they may impact your operations."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
  docker_current_version="$(date +%y.%m.0 -d @$(( $(date +%s) - 2592000)))"
  do_version_check "$docker_current_version" "$docker_version"
  if [ $? -eq 11 ]; then
    info -c "$check"
    info "       * Using $docker_version, verify is it up to date as deemed necessary"
    info "       * Your operating system vendor may provide support and security maintenance for Docker"
    logcheckresult "INFO" "Using $docker_version"
  else
    pass -c "$check"
    info "       * Using $docker_version which is current"
    info "       * Check with your operating system vendor for support and security maintenance for Docker"
    logcheckresult "PASS" "Using $docker_version"
  fi
}

check_1_2() {
  local id="1.2"
  local desc="Linux Hosts Specific Configuration"
  local check="$id - $desc"
  info "$check"
}

check_1_2_1() {
  local id="1.2.1"
  local desc="Ensure a separate partition for containers has been created (Scored)"
  local remediation="For new installations, you should create a separate partition for the /var/lib/docker mount point. For systems that have already been installed, you should use the Logical Volume Manager (LVM) within Linux to create a new partition."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  docker_root_dir=$(docker info -f '{{ .DockerRootDir }}')
  if docker info | grep -q userns ; then
    docker_root_dir=$(readlink -f "$docker_root_dir/..")
  fi

  if mountpoint -q -- "$docker_root_dir" >/dev/null 2>&1; then
    pass -s "$check"
    logcheckresult "PASS"
  else
    warn -s "$check"
    logcheckresult "WARN"
  fi
}

check_1_2_2() { 
  local id="1.2.2"
  local desc="Ensure only trusted users are allowed to control Docker daemon (Scored)"
  local remediation="You should remove any untrusted users from the docker group using command sudo gpasswd -d <your-user> docker or add trusted users to the docker group using command sudo usermod -aG docker <your-user>. You should not create a mapping of sensitive directories from the host to container volumes."
  local remediationImpact="Only trust user are allow to build and execute containers as normal user."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if command -v getent >/dev/null 2>&1; then
    docker_users=$(getent group docker)
  else
    docker_users=$(grep 'docker' /etc/group)
  fi
  docker_users=$(printf "%s" "$docker_users" | awk -F: '{print $4}')

  local doubtfulusers=""
  if [ -n "$dockertrustusers" ]; then
    for u in $(printf "%s" "$docker_users" | sed "s/,/ /g"); do
      if ! printf "%s" "$dockertrustusers" | grep -q "$u" ; then
        if [ -n "${doubtfulusers}" ]; then
          doubtfulusers="${doubtfulusers},$u"
        else
          doubtfulusers="$u"
        fi
      fi
    done
  else
    info -c "$check"
    info "      * Users: $docker_users"
    logcheckresult "INFO" "doubtfulusers" "$docker_users"
  fi

  if [ -n "${doubtfulusers}" ]; then
    warn -s "$check"
    warn "      * Doubtful users: $doubtfulusers"
    logcheckresult "WARN" "doubtfulusers" "$doubtfulusers"
  fi

  if [ -z "${doubtfulusers}" ] && [ -n "${dockertrustusers}" ]; then
    pass -s "$check"
    logcheckresult "PASS"
  fi
}

check_1_2_3() {
  local id="1.2.3"
  local desc="Ensure auditing is configured for the Docker daemon (Scored)"
  local remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w /usr/bin/dockerd -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/usr/bin/dockerd"
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep "$file" >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass -s "$check"
    logcheckresult "PASS"
  else
    warn -s "$check"
    logcheckresult "WARN"
  fi
}

check_1_2_4() {
  local id="1.2.4"
  local desc="Ensure auditing is configured for Docker files and directories - /var/lib/docker (Scored)"
  local remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w /var/lib/docker -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  directory="/var/lib/docker"
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
      else
        warn -s "$check"
        logcheckresult "WARN"
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    info -c "$check"
    info "       * Directory not found"
    logcheckresult "INFO" "Directory not found"
  fi
}

check_1_2_5() {
  local id="1.2.5"
  local desc="Ensure auditing is configured for Docker files and directories - /etc/docker (Scored)"
  local remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w /etc/docker -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
      else
        warn -s "$check"
        logcheckresult "WARN"
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    info -c "$check"
    info "       * Directory not found"
    logcheckresult "INFO" "Directory not found"
fi
}

check_1_2_6() {
  local id="1.2.6"
  local desc="Ensure auditing is configured for Docker files and directories - docker.service (Scored)"
  local remediation
  remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w $(systemctl show -p FragmentPath docker.service | sed 's/.*=//') -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="$(get_service_file docker.service)"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
      else
        warn -s "$check"
        logcheckresult "WARN"
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    info -c "$check"
    info "       * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_1_2_7() {
  local id="1.2.7"
  local desc="Ensure auditing is configured for Docker files and directories - docker.socket (Scored)"
  local remediation
  remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w $(systemctl show -p FragmentPath docker.socket | sed 's/.*=//') -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="$(get_service_file docker.socket)"
  if [ -e "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
      else
        warn -s "$check"
        logcheckresult "WARN"
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    info -c "$check"
    info "       * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_1_2_8() {
  local id="1.2.8"
  local desc="Ensure auditing is configured for Docker files and directories - /etc/default/docker (Scored)"
  local remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w /etc/default/docker -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
      else
        warn -s "$check"
        logcheckresult "WARN"
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    info -c "$check"
    info "       * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_1_2_9() {
  local id="1.2.9"
  local desc="Ensure auditing is configured for Docker files and directories - /etc/sysconfig/docker (Scored)"
  local remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w /etc/sysconfig/docker -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
      else
        warn -s "$check"
        logcheckresult "WARN"
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    info -c "$check"
    info "       * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_1_2_10() {
  local id="1.2.10"
  local desc="Ensure auditing is configured for Docker files and directories - /etc/docker/daemon.json (Scored)"
  local remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w /etc/docker/daemon.json -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
      else
        warn -s "$check"
        logcheckresult "WARN"
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    info -c "$check"
    info "        * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_1_2_11() {
  local id="1.2.11"
  local desc="Ensure auditing is configured for Docker files and directories - /usr/bin/containerd (Scored)"
  local remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w /usr/bin/containerd -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/usr/bin/containerd"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
      else
        warn -s "$check"
        logcheckresult "WARN"
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    info -c "$check"
    info "        * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_1_2_12() {
  local id="1.2.12"
  local desc="Ensure auditing is configured for Docker files and directories - /usr/sbin/runc (Scored)"
  local remediation="Install and configure auditd using command sudo apt-get install auditd. Add -w /usr/sbin/runc -k docker to the /etc/audit/rules.d/audit.rules file. Then restart the audit daemon using command service auditd restart."
  local remediationImpact="Audit can generate large log files. So you need to make sure that they are rotated and archived periodically. Create a separate partition for audit logs to avoid filling up other critical partitions."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  file="/usr/sbin/runc"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass -s "$check"
        logcheckresult "PASS"
      else
        warn -s "$check"
        logcheckresult "WARN"
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass -s "$check"
      logcheckresult "PASS"
    else
      warn -s "$check"
      logcheckresult "WARN"
    fi
  else
    info -c "$check"
    info "        * File not found"
    logcheckresult "INFO" "File not found"
  fi
}

check_1_end() {
  endsectionjson
}
