#!/bin/sh

check_5() {
  logit ""
  local id="5"
  local desc="Container Runtime"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_running_containers() {
  # If containers is empty, there are no running containers
  if [ -z "$containers" ]; then
    info "  * No containers running, skipping Section 5"
  else
    # Make the loop separator be a new-line in POSIX compliant fashion
    set -f; IFS=$'
  '
  fi
}

check_5_1() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.1"
  local desc="Ensure that, if applicable, an AppArmor Profile is enabled (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  no_apparmor_containers=""
  for c in $containers; do
    policy=$(docker inspect --format 'AppArmorProfile={{ .AppArmorProfile }}' "$c")

    if [ "$policy" = "AppArmorProfile=" ] || [ "$policy" = "AppArmorProfile=[]" ] || [ "$policy" = "AppArmorProfile=<no value>" ] || [ "$policy" = "AppArmorProfile=unconfined" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "     * No AppArmorProfile Found: $c"
	no_apparmor_containers="$no_apparmor_containers $c"
        fail=1
      else
        warn "     * No AppArmorProfile Found: $c"
	no_apparmor_containers="$no_apparmor_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none without AppArmor
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers with no AppArmorProfile" "$no_apparmor_containers"
  fi
}

check_5_2() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.2"
  local desc="Ensure that, if applicable, SELinux security options are set (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  no_securityoptions_containers=""
  for c in $containers; do
    policy=$(docker inspect --format 'SecurityOpt={{ .HostConfig.SecurityOpt }}' "$c")

    if [ "$policy" = "SecurityOpt=" ] || [ "$policy" = "SecurityOpt=[]" ] || [ "$policy" = "SecurityOpt=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "     * No SecurityOptions Found: $c"
	no_securityoptions_containers="$no_securityoptions_containers $c"
        fail=1
      else
        warn "     * No SecurityOptions Found: $c"
	no_securityoptions_containers="$no_securityoptions_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none without SELinux
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers with no SecurityOptions" "$no_securityoptions_containers"
  fi
}

check_5_3() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.3"
  local desc="Ensure that Linux kernel capabilities are restricted within containers (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  caps_containers=""
  for c in $containers; do
    container_caps=$(docker inspect --format 'CapAdd={{ .HostConfig.CapAdd}}' "$c")
    caps=$(echo "$container_caps" | tr "[:lower:]" "[:upper:]" | \
      sed 's/CAPADD/CapAdd/' | \
      sed -r "s/AUDIT_WRITE|CHOWN|DAC_OVERRIDE|FOWNER|FSETID|KILL|MKNOD|NET_BIND_SERVICE|NET_RAW|SETFCAP|SETGID|SETPCAP|SETUID|SYS_CHROOT|\s//g")

    if [ "$caps" != 'CapAdd=' ] && [ "$caps" != 'CapAdd=[]' ] && [ "$caps" != 'CapAdd=<no value>' ] && [ "$caps" != 'CapAdd=<nil>' ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "     * Capabilities added: $caps to $c"
	caps_containers="$caps_containers $c"
        fail=1
      else
        warn "     * Capabilities added: $caps to $c"
	caps_containers="$caps_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with extra capabilities
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Capabilities added for containers" "$caps_containers"
  fi
}

check_5_4() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.4"
  local desc="Ensure that privileged containers are not used (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  privileged_containers=""
  for c in $containers; do
    privileged=$(docker inspect --format '{{ .HostConfig.Privileged }}' "$c")

    if [ "$privileged" = "true" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "     * Container running in Privileged mode: $c"
	privileged_containers="$privileged_containers $c"
        fail=1
      else
        warn "     * Container running in Privileged mode: $c"
	privileged_containers="$privileged_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no privileged containers
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers running in privileged mode" "$privileged_containers"
  fi
}

check_5_5() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.5"
  local desc="Ensure sensitive host system directories are not mounted on containers (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  # List of sensitive directories to test for. Script uses new-lines as a separator.
  # Note the lack of identation. It needs it for the substring comparison.
  sensitive_dirs='/
/boot
/dev
/etc
/lib
/proc
/sys
/usr'
  fail=0
  sensitive_mount_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .VolumesRW }}' "$c" 2>/dev/null 1>&2; then
      volumes=$(docker inspect --format '{{ .VolumesRW }}' "$c")
    else
      volumes=$(docker inspect --format '{{ .Mounts }}' "$c")
    fi
    # Go over each directory in sensitive dir and see if they exist in the volumes
    for v in $sensitive_dirs; do
      sensitive=0
      if echo "$volumes" | grep -e "{.*\s$v\s.*true\s.*}" 2>/tmp/null 1>&2; then
        sensitive=1
      fi
      if [ $sensitive -eq 1 ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn -s "$check"
          warn "     * Sensitive directory $v mounted in: $c"
	  sensitive_mount_containers="$sensitive_mount_containers $c:$v"
          fail=1
        else
          warn "     * Sensitive directory $v mounted in: $c"
	  sensitive_mount_containers="$sensitive_mount_containers $c:$v"
        fi
      fi
    done
  done
  # We went through all the containers and found none with sensitive mounts
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers with sensitive directories mounted" "$sensitive_mount_containers"
  fi
}

check_5_6() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.6"
  local desc="Ensure sshd is not run within containers (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  ssh_exec_containers=""
  printcheck=0
  for c in $containers; do

    processes=$(docker exec "$c" ps -el 2>/dev/null | grep -c sshd | awk '{print $1}')
    if [ "$processes" -ge 1 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "     * Container running sshd: $c"
	ssh_exec_containers="$ssh_exec_containers $c"
        fail=1
        printcheck=1
      else
        warn "     * Container running sshd: $c"
	ssh_exec_containers="$ssh_exec_containers $c"
      fi
    fi

    exec_check=$(docker exec "$c" ps -el 2>/dev/null)
    if [ $? -eq 255 ]; then
        if [ $printcheck -eq 0 ]; then
          warn -s "$check"
          printcheck=1
        fi
      warn "     * Docker exec fails: $c"
      ssh_exec_containers="$ssh_exec_containers $c"
      fail=1
    fi

  done
  # We went through all the containers and found none with sshd
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers with sshd/docker exec failures" "$ssh_exec_containers"
  fi
}

check_5_7() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.7"
  local desc="Ensure privileged ports are not mapped within containers (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  privileged_port_containers=""
  for c in $containers; do
    # Port format is private port -> ip: public port
    ports=$(docker port "$c" | awk '{print $0}' | cut -d ':' -f2)

    # iterate through port range (line delimited)
    for port in $ports; do
    if [ -n "$port" ] && [ "$port" -lt 1024 ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn -s "$check"
          warn "     * Privileged Port in use: $port in $c"
	  privileged_port_containers="$privileged_port_containers $c:$port"
          fail=1
        else
          warn "     * Privileged Port in use: $port in $c"
	  privileged_port_containers="$privileged_port_containers $c:$port"
        fi
      fi
    done
  done
  # We went through all the containers and found no privileged ports
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers using privileged ports" "$privileged_port_containers"
  fi
}

check_5_8() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.8"
  local desc="Ensure that only needed ports are open on the container (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_5_9() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.9"
  local desc="Ensure that the host's network namespace is not shared (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  net_host_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'NetworkMode={{ .HostConfig.NetworkMode }}' "$c")

    if [ "$mode" = "NetworkMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "     * Container running with networking mode 'host': $c"
	net_host_containers="$net_host_containers $c"
        fail=1
      else
        warn "     * Container running with networking mode 'host': $c"
	net_host_containers="$net_host_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no Network Mode host
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers running with networking mode 'host'" "$net_host_containers"
  fi
}

check_5_10() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.10"
  local desc="Ensure that the memory usage for containers is limited (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  mem_unlimited_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .Config.Memory }}' "$c" 2> /dev/null 1>&2; then
      memory=$(docker inspect --format '{{ .Config.Memory }}' "$c")
    else
      memory=$(docker inspect --format '{{ .HostConfig.Memory }}' "$c")
    fi

    if [ "$memory" = "0" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Container running without memory restrictions: $c"
	mem_unlimited_containers="$mem_unlimited_containers $c"
        fail=1
      else
        warn "      * Container running without memory restrictions: $c"
	mem_unlimited_containers="$mem_unlimited_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no lack of Memory restrictions
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Container running without memory restrictions" "$mem_unlimited_containers"
  fi
}

check_5_11() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.11"
  local desc="Ensure that CPU priority is set appropriately on containers (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  cpu_unlimited_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .Config.CpuShares }}' "$c" 2> /dev/null 1>&2; then
      shares=$(docker inspect --format '{{ .Config.CpuShares }}' "$c")
    else
      shares=$(docker inspect --format '{{ .HostConfig.CpuShares }}' "$c")
    fi

    if [ "$shares" = "0" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Container running without CPU restrictions: $c"
        cpu_unlimited_containers="$cpu_unlimited_containers $c"
        fail=1
      else
        warn "      * Container running without CPU restrictions: $c"
        cpu_unlimited_containers="$cpu_unlimited_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no lack of CPUShare restrictions
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers running without CPU restrictions" "$cpu_unlimited_containers"
  fi
}

check_5_12() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.12"
  local desc="Ensure that the container's root filesystem is mounted as read only (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  fsroot_mount_containers=""
  for c in $containers; do
   read_status=$(docker inspect --format '{{ .HostConfig.ReadonlyRootfs }}' "$c")

    if [ "$read_status" = "false" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Container running with root FS mounted R/W: $c"
	fsroot_mount_containers="$fsroot_mount_containers $c"
        fail=1
      else
        warn "      * Container running with root FS mounted R/W: $c"
	fsroot_mount_containers="$fsroot_mount_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no R/W FS mounts
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers running with root FS mounted R/W" "$fsroot_mount_containers"
  fi
}

check_5_13() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.13"
  local desc="Ensure that incoming container traffic is bound to a specific host interface (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  incoming_unbound_containers=""
  for c in $containers; do
    for ip in $(docker port "$c" | awk '{print $3}' | cut -d ':' -f1); do
      if [ "$ip" = "0.0.0.0" ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn -s "$check"
          warn "      * Port being bound to wildcard IP: $ip in $c"
          incoming_unbound_containers="$incoming_unbound_containers $c:$ip"
          fail=1
        else
          warn "      * Port being bound to wildcard IP: $ip in $c"
          incoming_unbound_containers="$incoming_unbound_containers $c:$ip"
        fi
      fi
    done
  done
  # We went through all the containers and found no ports bound to 0.0.0.0
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers with port bound to wildcard IP" "$incoming_unbound_containers"
  fi
}

check_5_14() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.14"
  local desc="Ensure that the 'on-failure' container restart policy is set to '5' (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  maxretry_unset_containers=""
  for c in $containers; do
    policy=$(docker inspect --format MaximumRetryCount='{{ .HostConfig.RestartPolicy.MaximumRetryCount }}' "$c")

    if [ "$policy" != "MaximumRetryCount=5" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * MaximumRetryCount is not set to 5: $c"
	maxretry_unset_containers="$maxretry_unset_containers $c"
        fail=1
      else
        warn "      * MaximumRetryCount is not set to 5: $c"
	maxretry_unset_containers="$maxretry_unset_containers $c"
      fi
    fi
  done
  # We went through all the containers and they all had MaximumRetryCount=5
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers with MaximumRetryCount not set to 5" "$maxretry_unset_containers"
  fi
}

check_5_15() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.15"
  local desc="Ensure that the host's process namespace is not shared (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  pidns_shared_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'PidMode={{.HostConfig.PidMode }}' "$c")

    if [ "$mode" = "PidMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Host PID namespace being shared with: $c"
        pidns_shared_containers="$pidns_shared_containers $c"
        fail=1
      else
        warn "      * Host PID namespace being shared with: $c"
        pidns_shared_containers="$pidns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with PidMode as host
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers sharing host PID namespace" "$pidns_shared_containers"
  fi
}

check_5_16() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.16"
  local desc="Ensure that the host's IPC namespace is not shared (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  ipcns_shared_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'IpcMode={{.HostConfig.IpcMode }}' "$c")

    if [ "$mode" = "IpcMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Host IPC namespace being shared with: $c"
        ipcns_shared_containers="$ipcns_shared_containers $c"
        fail=1
      else
        warn "      * Host IPC namespace being shared with: $c"
        ipcns_shared_containers="$ipcns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with IPCMode as host
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers sharing host IPC namespace" "$ipcns_shared_containers"
  fi
}

check_5_17() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.17"
  local desc="Ensure that host devices are not directly exposed to containers (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  hostdev_exposed_containers=""
  for c in $containers; do
    devices=$(docker inspect --format 'Devices={{ .HostConfig.Devices }}' "$c")

    if [ "$devices" != "Devices=" ] && [ "$devices" != "Devices=[]" ] && [ "$devices" != "Devices=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info -c "$check"
        info "      * Container has devices exposed directly: $c"
        hostdev_exposed_containers="$hostdev_exposed_containers $c"
        fail=1
      else
        info "      * Container has devices exposed directly: $c"
        hostdev_exposed_containers="$hostdev_exposed_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with devices
  if [ $fail -eq 0 ]; then
      pass -c "$check"
      logcheckresult "PASS"
  else
      logcheckresult "INFO" "Containers with host devices exposed directly" "$hostdev_exposed_containers"
  fi
}

check_5_18() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.18"
  local desc="Ensure that the default ulimit is overwritten at runtime if needed (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  no_ulimit_containers=""
  for c in $containers; do
    ulimits=$(docker inspect --format 'Ulimits={{ .HostConfig.Ulimits }}' "$c")

    if [ "$ulimits" = "Ulimits=" ] || [ "$ulimits" = "Ulimits=[]" ] || [ "$ulimits" = "Ulimits=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info -c "$check"
        info "      * Container no default ulimit override: $c"
        no_ulimit_containers="$no_ulimit_containers $c"
        fail=1
      else
        info "      * Container no default ulimit override: $c"
        no_ulimit_containers="$no_ulimit_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none without Ulimits
  if [ $fail -eq 0 ]; then
      pass -c "$check"
      logcheckresult "PASS"
  else
      logcheckresult "INFO" "Containers with no default ulimit override" "$no_ulimit_containers"
  fi
}

check_5_19() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.19"
  local desc="Ensure mount propagation mode is not set to shared (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  mountprop_shared_containers=""
  for c in $containers; do
    if docker inspect --format 'Propagation={{range $mnt := .Mounts}} {{json $mnt.Propagation}} {{end}}' "$c" | \
     grep shared 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Mount propagation mode is shared: $c"
        mountprop_shared_containers="$mountprop_shared_containers $c"
        fail=1
      else
        warn "      * Mount propagation mode is shared: $c"
        mountprop_shared_containers="$mountprop_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with shared propagation mode
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
    logcheckresult "WARN" "Containers with shared mount propagation" "$mountprop_shared_containers"
  fi
}

check_5_20() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.20"
  local desc="Ensure that the host's UTS namespace is not shared (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  utcns_shared_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'UTSMode={{.HostConfig.UTSMode }}' "$c")

    if [ "$mode" = "UTSMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Host UTS namespace being shared with: $c"
        utcns_shared_containers="$utcns_shared_containers $c"
        fail=1
      else
        warn "      * Host UTS namespace being shared with: $c"
        utcns_shared_containers="$utcns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with UTSMode as host
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers sharing host UTS namespace" "$utcns_shared_containers"
  fi
}

check_5_21() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.21"
  local desc="Ensurethe default seccomp profile is not Disabled (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  seccomp_disabled_containers=""
  for c in $containers; do
    if docker inspect --format 'SecurityOpt={{.HostConfig.SecurityOpt }}' "$c" | \
      grep -E 'seccomp:unconfined|seccomp=unconfined' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Default seccomp profile disabled: $c"
        seccomp_disabled_containers="$seccomp_disabled_containers $c"
        fail=1
      else
        warn "      * Default seccomp profile disabled: $c"
        seccomp_disabled_containers="$seccomp_disabled_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with default secomp profile disabled
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers with default seccomp profile disabled" "$seccomp_disabled_containers"
  fi
}

check_5_22() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.22"
  local desc="Ensure that docker exec commands are not used with the privileged option (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_5_23() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.23"
  local desc="Ensure that docker exec commands are not used with the user=root option (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_5_24() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.24"
  local desc="Ensure that cgroup usage is confirmed (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  unexpected_cgroup_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'CgroupParent={{.HostConfig.CgroupParent }}x' "$c")

    if [ "$mode" != "CgroupParent=x" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Confirm cgroup usage: $c"
        unexpected_cgroup_containers="$unexpected_cgroup_containers $c"
        fail=1
      else
        warn "      * Confirm cgroup usage: $c"
        unexpected_cgroup_containers="$unexpected_cgroup_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with UTSMode as host
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers using unexpected cgroup" "$unexpected_cgroup_containers"
  fi
}

check_5_25() {
  if [ -z "$containers" ]; then
    return
  fi
  local id="5.25"
  local desc="Ensure that the container is restricted from acquiring additional privileges (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  addprivs_containers=""
  for c in $containers; do
    if ! docker inspect --format 'SecurityOpt={{.HostConfig.SecurityOpt }}' "$c" | grep 'no-new-privileges' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Privileges not restricted: $c"
        addprivs_containers="$addprivs_containers $c"
        fail=1
      else
        warn "      * Privileges not restricted: $c"
        addprivs_containers="$addprivs_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with capability to acquire additional privileges
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers without restricted privileges" "$addprivs_containers"
  fi
}

check_5_26() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.26"
  local desc="Ensure that container health is checked at runtime (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  nohealthcheck_containers=""
  for c in $containers; do
    if ! docker inspect --format '{{ .Id }}: Health={{ .State.Health.Status }}' "$c" 2>/dev/null 1>&2; then
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Health check not set: $c"
        nohealthcheck_containers="$nohealthcheck_containers $c"
        fail=1
      else
        warn "      * Health check not set: $c"
        nohealthcheck_containers="$nohealthcheck_containers $c"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers without health check" "$nohealthcheck_containers"
  fi
}

check_5_27() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.27"
  local desc="Ensure that Docker commands always make use of the latest version of their image (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  info -c "$check"
  logcheckresult "INFO"
}

check_5_28() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.28"
  local desc="Ensure that the PIDs cgroup limit is used (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  nopids_limit_containers=""
  for c in $containers; do
    pidslimit="$(docker inspect --format '{{.HostConfig.PidsLimit }}' "$c")"

    if [ "$pidslimit" = "0" ] || [  "$pidslimit" = "<nil>" ] || [  "$pidslimit" = "-1" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * PIDs limit not set: $c"
        nopids_limit_containers="$nopids_limit_containers $c"
        fail=1
      else
        warn "      * PIDs limit not set: $c"
        nopids_limit_containers="$nopids_limit_containers $c"
      fi
    fi
  done
  # We went through all the containers and found all with PIDs limit
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers without PIDs cgroup limit" "$nopids_limit_containers"
  fi
}

check_5_29() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.29"
  local desc="Ensure that Docker's default bridge "docker0" is not used (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  docker_network_containers=""
  networks=$(docker network ls -q 2>/dev/null)
  for net in $networks; do
    if docker network inspect --format '{{ .Options }}' "$net" 2>/dev/null | grep "com.docker.network.bridge.name:docker0" >/dev/null 2>&1; then
      docker0Containers=$(docker network inspect --format='{{ range $k, $v := .Containers }} {{ $k }} {{ end }}' "$net" | \
        sed -e 's/^ //' -e 's/  /\n/g' 2>/dev/null)

        if [ -n "$docker0Containers" ]; then
          if [ $fail -eq 0 ]; then
            info -c "$check"
            fail=1
          fi
          for c in $docker0Containers; do
            if [ -z "$exclude" ]; then
              cName=$(docker inspect --format '{{.Name}}' "$c" 2>/dev/null | sed 's/\///g')
            else
              pattern=$(echo "$exclude" | sed 's/,/|/g')
              cName=$(docker inspect --format '{{.Name}}' "$c" 2>/dev/null | sed 's/\///g' | grep -Ev "$pattern" )
            fi
            if [ -n "$cName" ]; then
              info "      * Container in docker0 network: $cName"
              docker_network_containers="$docker_network_containers $c:$cName"
            fi
          done
        fi
    fi
  done
  # We went through all the containers and found none in docker0 network
  if [ $fail -eq 0 ]; then
      pass -c "$check"
      logcheckresult "PASS"
  else
      logcheckresult "INFO" "Containers using docker0 network" "$docker_network_containers"
  fi
}

check_5_30() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.30"
  local desc="Ensure that the host's user namespaces are not shared (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  hostns_shared_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .HostConfig.UsernsMode }}' "$c" 2>/dev/null | grep -i 'host' >/dev/null 2>&1; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Namespace shared: $c"
        hostns_shared_containers="$hostns_shared_containers $c"
        fail=1
      else
        warn "      * Namespace shared: $c"
        hostns_shared_containers="$hostns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with host's user namespace shared
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers sharing host user namespace" "$hostns_shared_containers"
  fi
}

check_5_31() {
  if [ -z "$containers" ]; then
    return
  fi

  local id="5.31"
  local desc="Ensure that the Docker socket is not mounted inside any containers (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  docker_sock_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .Mounts }}' "$c" 2>/dev/null | grep 'docker.sock' >/dev/null 2>&1; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        warn "      * Docker socket shared: $c"
        docker_sock_containers="$docker_sock_containers $c"
        fail=1
      else
        warn "      * Docker socket shared: $c"
        docker_sock_containers="$docker_sock_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with docker.sock shared
  if [ $fail -eq 0 ]; then
      pass -s "$check"
      logcheckresult "PASS"
  else
      logcheckresult "WARN" "Containers sharing docker socket" "$docker_sock_containers"
  fi
}

check_5_end() {
  endsectionjson
}
