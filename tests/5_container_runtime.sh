#!/bin/sh

check_5() {
  logit "\n"
  id_5="5"
  desc_5="Container Runtime"
  check_5="$id_5 - $desc_5"
  info "$check_5"
  startsectionjson "$id_5" "$desc_5"
}

check_running_containers() {
  # If containers is empty, there are no running containers
  if [ -z "$containers" ]; then
    info "  * No containers running, skipping Section 5"
    running_containers=0
  else
    running_containers=1
    # Make the loop separator be a new-line in POSIX compliant fashion
    set -f; IFS=$'
  '
  fi
}

# 5.1
check_5_1() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_1="5.1"
  desc_5_1="Ensure that, if applicable, an AppArmor Profile is enabled (Scored)"
  check_5_1="$id_5_1  - $desc_5_1"
  starttestjson "$id_5_1" "$desc_5_1"

  totalChecks=$((totalChecks + 1))

  fail=0
  no_apparmor_containers=""
  for c in $containers; do
    policy=$(docker inspect --format 'AppArmorProfile={{ .AppArmorProfile }}' "$c")

    if [ "$policy" = "AppArmorProfile=" ] || [ "$policy" = "AppArmorProfile=[]" ] || [ "$policy" = "AppArmorProfile=<no value>" ] || [ "$policy" = "AppArmorProfile=unconfined" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_1"
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
      pass "$check_5_1"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers with no AppArmorProfile" "$no_apparmor_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.2
check_5_2() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_2="5.2"
  desc_5_2="Ensure that, if applicable, SELinux security options are set (Scored)"
  check_5_2="$id_5_2  - $desc_5_2"
  starttestjson "$id_5_2" "$desc_5_2"

  totalChecks=$((totalChecks + 1))

  fail=0
  no_securityoptions_containers=""
  for c in $containers; do
    policy=$(docker inspect --format 'SecurityOpt={{ .HostConfig.SecurityOpt }}' "$c")

    if [ "$policy" = "SecurityOpt=" ] || [ "$policy" = "SecurityOpt=[]" ] || [ "$policy" = "SecurityOpt=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_2"
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
      pass "$check_5_2"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers with no SecurityOptions" "$no_securityoptions_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.3
check_5_3() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_3="5.3"
  desc_5_3="Ensure that Linux kernel capabilities are restricted within containers (Scored)"
  check_5_3="$id_5_3  - $desc_5_3"
  starttestjson "$id_5_3" "$desc_5_3"

  totalChecks=$((totalChecks + 1))

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
        warn "$check_5_3"
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
      pass "$check_5_3"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Capabilities added for containers" "$caps_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.4
check_5_4() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_4="5.4"
  desc_5_4="Ensure that privileged containers are not used (Scored)"
  check_5_4="$id_5_4  - $desc_5_4"
  starttestjson "$id_5_4" "$desc_5_4"

  totalChecks=$((totalChecks + 1))

  fail=0
  privileged_containers=""
  for c in $containers; do
    privileged=$(docker inspect --format '{{ .HostConfig.Privileged }}' "$c")

    if [ "$privileged" = "true" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_4"
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
      pass "$check_5_4"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers running in privileged mode" "$privileged_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.5
check_5_5() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_5="5.5"
  desc_5_5="Ensure sensitive host system directories are not mounted on containers (Scored)"
  check_5_5="$id_5_5  - $desc_5_5"
  starttestjson "$id_5_5" "$desc_5_5"

  totalChecks=$((totalChecks + 1))

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
          warn "$check_5_5"
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
      pass "$check_5_5"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers with sensitive directories mounted" "$sensitive_mount_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.6
check_5_6() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_6="5.6"
  desc_5_6="Ensure sshd is not run within containers (Scored)"
  check_5_6="$id_5_6  - $desc_5_6"
  starttestjson "$id_5_6" "$desc_5_6"

  totalChecks=$((totalChecks + 1))

  fail=0
  ssh_exec_containers=""
  printcheck=0
  for c in $containers; do

    processes=$(docker exec "$c" ps -el 2>/dev/null | grep -c sshd | awk '{print $1}')
    if [ "$processes" -ge 1 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_6"
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
          warn "$check_5_6"
          printcheck=1
        fi
      warn "     * Docker exec fails: $c"
      ssh_exec_containers="$ssh_exec_containers $c"
      fail=1
    fi

  done
  # We went through all the containers and found none with sshd
  if [ $fail -eq 0 ]; then
      pass "$check_5_6"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers with sshd/docker exec failures" "$ssh_exec_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.7
check_5_7() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_7="5.7"
  desc_5_7="Ensure privileged ports are not mapped within containers (Scored)"
  check_5_7="$id_5_7  - $desc_5_7"
  starttestjson "$id_5_7" "$desc_5_7"

  totalChecks=$((totalChecks + 1))

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
          warn "$check_5_7"
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
      pass "$check_5_7"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers using privileged ports" "$privileged_port_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.8
check_5_8() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_8="5.8"
  desc_5_8="Ensure that only needed ports are open on the container (Not Scored)"
  check_5_8="$id_5_8  - $desc_5_8"
  starttestjson "$id_5_8" "$desc_5_8"

  totalChecks=$((totalChecks + 1))
  note "$check_5_8"
  resulttestjson "NOTE"
  currentScore=$((currentScore + 0))
}

# 5.9
check_5_9() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_9="5.9"
  desc_5_9="Ensure that the host's network namespace is not shared (Scored)"
  check_5_9="$id_5_9  - $desc_5_9"
  starttestjson "$id_5_9" "$desc_5_9"

  totalChecks=$((totalChecks + 1))

  fail=0
  net_host_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'NetworkMode={{ .HostConfig.NetworkMode }}' "$c")

    if [ "$mode" = "NetworkMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_9"
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
      pass "$check_5_9"
      resulttestjson "PASS"
      currentScore=$((currentScore + 0))
  else
      resulttestjson "WARN" "Containers running with networking mode 'host'" "$net_host_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.10
check_5_10() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_10="5.10"
  desc_5_10="Ensure that the memory usage for containers is limited (Scored)"
  check_5_10="$id_5_10  - $desc_5_10"
  starttestjson "$id_5_10" "$desc_5_10"

  totalChecks=$((totalChecks + 1))

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
        warn "$check_5_10"
        warn "     * Container running without memory restrictions: $c"
	mem_unlimited_containers="$mem_unlimited_containers $c"
        fail=1
      else
        warn "     * Container running without memory restrictions: $c"
	mem_unlimited_containers="$mem_unlimited_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no lack of Memory restrictions
  if [ $fail -eq 0 ]; then
      pass "$check_5_10"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Container running without memory restrictions" "$mem_unlimited_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.11
check_5_11() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_11="5.11"
  desc_5_11="Ensure that CPU priority is set appropriately on containers (Scored)"
  check_5_11="$id_5_11  - $desc_5_11"
  starttestjson "$id_5_11" "$desc_5_11"

  totalChecks=$((totalChecks + 1))

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
        warn "$check_5_11"
        warn "     * Container running without CPU restrictions: $c"
        cpu_unlimited_containers="$cpu_unlimited_containers $c"
        fail=1
      else
        warn "     * Container running without CPU restrictions: $c"
        cpu_unlimited_containers="$cpu_unlimited_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no lack of CPUShare restrictions
  if [ $fail -eq 0 ]; then
      pass "$check_5_11"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers running without CPU restrictions" "$cpu_unlimited_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.12
check_5_12() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_12="5.12"
  desc_5_12="Ensure that the container's root filesystem is mounted as read only (Scored)"
  check_5_12="$id_5_12  - $desc_5_12"
  starttestjson "$id_5_12" "$desc_5_12"

  totalChecks=$((totalChecks + 1))

  fail=0
  fsroot_mount_containers=""
  for c in $containers; do
   read_status=$(docker inspect --format '{{ .HostConfig.ReadonlyRootfs }}' "$c")

    if [ "$read_status" = "false" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_12"
        warn "     * Container running with root FS mounted R/W: $c"
	fsroot_mount_containers="$fsroot_mount_containers $c"
        fail=1
      else
        warn "     * Container running with root FS mounted R/W: $c"
	fsroot_mount_containers="$fsroot_mount_containers $c"
      fi
    fi
  done
  # We went through all the containers and found no R/W FS mounts
  if [ $fail -eq 0 ]; then
      pass "$check_5_12"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers running with root FS mounted R/W" "$fsroot_mount_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.13
check_5_13() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_13="5.13"
  desc_5_13="Ensure that incoming container traffic is bound to a specific host interface (Scored)"
  check_5_13="$id_5_13  - $desc_5_13"
  starttestjson "$id_5_13" "$desc_5_13"

  totalChecks=$((totalChecks + 1))

  fail=0
  incoming_unbound_containers=""
  for c in $containers; do
    for ip in $(docker port "$c" | awk '{print $3}' | cut -d ':' -f1); do
      if [ "$ip" = "0.0.0.0" ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_5_13"
          warn "     * Port being bound to wildcard IP: $ip in $c"
          incoming_unbound_containers="$incoming_unbound_containers $c:$ip"
          fail=1
        else
          warn "     * Port being bound to wildcard IP: $ip in $c"
          incoming_unbound_containers="$incoming_unbound_containers $c:$ip"
        fi
      fi
    done
  done
  # We went through all the containers and found no ports bound to 0.0.0.0
  if [ $fail -eq 0 ]; then
      pass "$check_5_13"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers with port bound to wildcard IP" "$incoming_unbound_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.14
check_5_14() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_14="5.14"
  desc_5_14="Ensure that the 'on-failure' container restart policy is set to '5' (Scored)"
  check_5_14="$id_5_14  - $desc_5_14"
  starttestjson "$id_5_14" "$desc_5_14"

  totalChecks=$((totalChecks + 1))

  fail=0
  maxretry_unset_containers=""
  for c in $containers; do
    policy=$(docker inspect --format MaximumRetryCount='{{ .HostConfig.RestartPolicy.MaximumRetryCount }}' "$c")

    if [ "$policy" != "MaximumRetryCount=5" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_14"
        warn "     * MaximumRetryCount is not set to 5: $c"
	maxretry_unset_containers="$maxretry_unset_containers $c"
        fail=1
      else
        warn "     * MaximumRetryCount is not set to 5: $c"
	maxretry_unset_containers="$maxretry_unset_containers $c"
      fi
    fi
  done
  # We went through all the containers and they all had MaximumRetryCount=5
  if [ $fail -eq 0 ]; then
      pass "$check_5_14"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers with MaximumRetryCount not set to 5" "$maxretry_unset_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.15
check_5_15() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_15="5.15"
  desc_5_15="Ensure that the host's process namespace is not shared (Scored)"
  check_5_15="$id_5_15  - $desc_5_15"
  starttestjson "$id_5_15" "$desc_5_15"

  totalChecks=$((totalChecks + 1))

  fail=0
  pidns_shared_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'PidMode={{.HostConfig.PidMode }}' "$c")

    if [ "$mode" = "PidMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_15"
        warn "     * Host PID namespace being shared with: $c"
        pidns_shared_containers="$pidns_shared_containers $c"
        fail=1
      else
        warn "     * Host PID namespace being shared with: $c"
        pidns_shared_containers="$pidns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with PidMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_15"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers sharing host PID namespace" "$pidns_shared_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.16
check_5_16() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_16="5.16"
  desc_5_16="Ensure that the host's IPC namespace is not shared (Scored)"
  check_5_16="$id_5_16  - $desc_5_16"
  starttestjson "$id_5_16" "$desc_5_16"

  totalChecks=$((totalChecks + 1))

  fail=0
  ipcns_shared_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'IpcMode={{.HostConfig.IpcMode }}' "$c")

    if [ "$mode" = "IpcMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_16"
        warn "     * Host IPC namespace being shared with: $c"
        ipcns_shared_containers="$ipcns_shared_containers $c"
        fail=1
      else
        warn "     * Host IPC namespace being shared with: $c"
        ipcns_shared_containers="$ipcns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with IPCMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_16"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers sharing host IPC namespace" "$ipcns_shared_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.17
check_5_17() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_17="5.17"
  desc_5_17="Ensure that host devices are not directly exposed to containers (Not Scored)"
  check_5_17="$id_5_17  - $desc_5_17"
  starttestjson "$id_5_17" "$desc_5_17"

  totalChecks=$((totalChecks + 1))

  fail=0
  hostdev_exposed_containers=""
  for c in $containers; do
    devices=$(docker inspect --format 'Devices={{ .HostConfig.Devices }}' "$c")

    if [ "$devices" != "Devices=" ] && [ "$devices" != "Devices=[]" ] && [ "$devices" != "Devices=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_5_17"
        info "     * Container has devices exposed directly: $c"
        hostdev_exposed_containers="$hostdev_exposed_containers $c"
        fail=1
      else
        info "     * Container has devices exposed directly: $c"
        hostdev_exposed_containers="$hostdev_exposed_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with devices
  if [ $fail -eq 0 ]; then
      pass "$check_5_17"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "INFO" "Containers with host devices exposed directly" "$hostdev_exposed_containers"
      currentScore=$((currentScore + 0))
  fi
}

# 5.18
check_5_18() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_18="5.18"
  desc_5_18="Ensure that the default ulimit is overwritten at runtime if needed (Not Scored)"
  check_5_18="$id_5_18  - $desc_5_18"
  starttestjson "$id_5_18" "$desc_5_18"

  totalChecks=$((totalChecks + 1))

  fail=0
  no_ulimit_containers=""
  for c in $containers; do
    ulimits=$(docker inspect --format 'Ulimits={{ .HostConfig.Ulimits }}' "$c")

    if [ "$ulimits" = "Ulimits=" ] || [ "$ulimits" = "Ulimits=[]" ] || [ "$ulimits" = "Ulimits=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_5_18"
        info "     * Container no default ulimit override: $c"
        no_ulimit_containers="$no_ulimit_containers $c"
        fail=1
      else
        info "     * Container no default ulimit override: $c"
        no_ulimit_containers="$no_ulimit_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none without Ulimits
  if [ $fail -eq 0 ]; then
      pass "$check_5_18"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "INFO" "Containers with no default ulimit override" "$no_ulimit_containers"
      currentScore=$((currentScore + 0))
  fi
}

# 5.19
check_5_19() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_19="5.19"
  desc_5_19="Ensure mount propagation mode is not set to shared (Scored)"
  check_5_19="$id_5_19  - $desc_5_19"
  starttestjson "$id_5_19" "$desc_5_19"

  totalChecks=$((totalChecks + 1))

  fail=0
  mountprop_shared_containers=""
  for c in $containers; do
    if docker inspect --format 'Propagation={{range $mnt := .Mounts}} {{json $mnt.Propagation}} {{end}}' "$c" | \
     grep shared 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_19"
        warn "     * Mount propagation mode is shared: $c"
        mountprop_shared_containers="$mountprop_shared_containers $c"
        fail=1
      else
        warn "     * Mount propagation mode is shared: $c"
        mountprop_shared_containers="$mountprop_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with shared propagation mode
  if [ $fail -eq 0 ]; then
      pass "$check_5_19"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
    resulttestjson "WARN" "Containers with shared mount propagation" "$mountprop_shared_containers"
    currentScore=$((currentScore - 1))
  fi
}

# 5.20
check_5_20() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_20="5.20"
  desc_5_20="Ensure that the host's UTS namespace is not shared (Scored)"
  check_5_20="$id_5_20  - $desc_5_20"
  starttestjson "$id_5_20" "$desc_5_20"

  totalChecks=$((totalChecks + 1))

  fail=0
  utcns_shared_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'UTSMode={{.HostConfig.UTSMode }}' "$c")

    if [ "$mode" = "UTSMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_20"
        warn "     * Host UTS namespace being shared with: $c"
        utcns_shared_containers="$utcns_shared_containers $c"
        fail=1
      else
        warn "     * Host UTS namespace being shared with: $c"
        utcns_shared_containers="$utcns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with UTSMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_20"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers sharing host UTS namespace" "$utcns_shared_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.21
check_5_21() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_21="5.21"
  desc_5_21="Ensurethe default seccomp profile is not Disabled (Scored)"
  check_5_21="$id_5_21  - $desc_5_21"
  starttestjson "$id_5_21" "$desc_5_21"

  totalChecks=$((totalChecks + 1))

  fail=0
  seccomp_disabled_containers=""
  for c in $containers; do
    if docker inspect --format 'SecurityOpt={{.HostConfig.SecurityOpt }}' "$c" | \
      grep -E 'seccomp:unconfined|seccomp=unconfined' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_21"
        warn "     * Default seccomp profile disabled: $c"
        seccomp_disabled_containers="$seccomp_disabled_containers $c"
        fail=1
      else
        warn "     * Default seccomp profile disabled: $c"
        seccomp_disabled_containers="$seccomp_disabled_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with default secomp profile disabled
  if [ $fail -eq 0 ]; then
      pass "$check_5_21"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers with default seccomp profile disabled" "$seccomp_disabled_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.22
check_5_22() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_22="5.22"
  desc_5_22="Ensure that docker exec commands are not used with the privileged option (Scored)"
  check_5_22="$id_5_22  - $desc_5_22"
  starttestjson "$id_5_22" "$desc_5_22"

  totalChecks=$((totalChecks + 1))
  note "$check_5_22"
  resulttestjson "NOTE"
  currentScore=$((currentScore + 0))
}

# 5.23
check_5_23() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_23="5.23"
  desc_5_23="Ensure that docker exec commands are not used with the user=root option (Not Scored)"
  check_5_23="$id_5_23  - $desc_5_23"
  starttestjson "$id_5_23" "$desc_5_23"

  totalChecks=$((totalChecks + 1))
  note "$check_5_23"
  resulttestjson "NOTE"
  currentScore=$((currentScore + 0))
}

# 5.24
check_5_24() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_24="5.24"
  desc_5_24="Ensure that cgroup usage is confirmed (Scored)"
  check_5_24="$id_5_24  - $desc_5_24"
  starttestjson "$id_5_24" "$desc_5_24"

  totalChecks=$((totalChecks + 1))

  fail=0
  unexpected_cgroup_containers=""
  for c in $containers; do
    mode=$(docker inspect --format 'CgroupParent={{.HostConfig.CgroupParent }}x' "$c")

    if [ "$mode" != "CgroupParent=x" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_24"
        warn "     * Confirm cgroup usage: $c"
        unexpected_cgroup_containers="$unexpected_cgroup_containers $c"
        fail=1
      else
        warn "     * Confirm cgroup usage: $c"
        unexpected_cgroup_containers="$unexpected_cgroup_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with UTSMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_24"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers using unexpected cgroup" "$unexpected_cgroup_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.25
check_5_25() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi
  id_5_25="5.25"
  desc_5_25="Ensure that the container is restricted from acquiring additional privileges (Scored)"
  check_5_25="$id_5_25  - $desc_5_25"
  starttestjson "$id_5_25" "$desc_5_25"

  totalChecks=$((totalChecks + 1))

  fail=0
  addprivs_containers=""
  for c in $containers; do
    if ! docker inspect --format 'SecurityOpt={{.HostConfig.SecurityOpt }}' "$c" | grep 'no-new-privileges' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_25"
        warn "     * Privileges not restricted: $c"
        addprivs_containers="$addprivs_containers $c"
        fail=1
      else
        warn "     * Privileges not restricted: $c"
        addprivs_containers="$addprivs_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with capability to acquire additional privileges
  if [ $fail -eq 0 ]; then
      pass "$check_5_25"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers without restricted privileges" "$addprivs_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.26
check_5_26() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_26="5.26"
  desc_5_26="Ensure that container health is checked at runtime (Scored)"
  check_5_26="$id_5_26  - $desc_5_26"
  starttestjson "$id_5_26" "$desc_5_26"

  totalChecks=$((totalChecks + 1))

  fail=0
  nohealthcheck_containers=""
  for c in $containers; do
    if ! docker inspect --format '{{ .Id }}: Health={{ .State.Health.Status }}' "$c" 2>/dev/null 1>&2; then
      if [ $fail -eq 0 ]; then
        warn "$check_5_26"
        warn "     * Health check not set: $c"
        nohealthcheck_containers="$nohealthcheck_containers $c"
        fail=1
      else
        warn "     * Health check not set: $c"
        nohealthcheck_containers="$nohealthcheck_containers $c"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
      pass "$check_5_26"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers without health check" "$nohealthcheck_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.27
check_5_27() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_27="5.27"
  desc_5_27="Ensure that Docker commands always make use of the latest version of their image (Not Scored)"
  check_5_27="$id_5_27  - $desc_5_27"
  starttestjson "$id_5_27" "$desc_5_27"

  totalChecks=$((totalChecks + 1))
  info "$check_5_27"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 5.28
check_5_28() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_28="5.28"
  desc_5_28="Ensure that the PIDs cgroup limit is used (Scored)"
  check_5_28="$id_5_28  - $desc_5_28"
  starttestjson "$id_5_28" "$desc_5_28"

  totalChecks=$((totalChecks + 1))

  fail=0
  nopids_limit_containers=""
  for c in $containers; do
    pidslimit="$(docker inspect --format '{{.HostConfig.PidsLimit }}' "$c")"

    if [ "$pidslimit" = "0" ] || [  "$pidslimit" = "<nil>" ] || [  "$pidslimit" = "-1" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_28"
        warn "     * PIDs limit not set: $c"
        nopids_limit_containers="$nopids_limit_containers $c"
        fail=1
      else
        warn "     * PIDs limit not set: $c"
        nopids_limit_containers="$nopids_limit_containers $c"
      fi
    fi
  done
  # We went through all the containers and found all with PIDs limit
  if [ $fail -eq 0 ]; then
      pass "$check_5_28"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers without PIDs cgroup limit" "$nopids_limit_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.29
check_5_29() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_29="5.29"
  desc_5_29="Ensure that Docker's default bridge "docker0" is not used (Not Scored)"
  check_5_29="$id_5_29  - $desc_5_29"
  starttestjson "$id_5_29" "$desc_5_29"

  totalChecks=$((totalChecks + 1))

  fail=0
  docker_network_containers=""
  networks=$(docker network ls -q 2>/dev/null)
  for net in $networks; do
    if docker network inspect --format '{{ .Options }}' "$net" 2>/dev/null | grep "com.docker.network.bridge.name:docker0" >/dev/null 2>&1; then
      docker0Containers=$(docker network inspect --format='{{ range $k, $v := .Containers }} {{ $k }} {{ end }}' "$net" | \
        sed -e 's/^ //' -e 's/  /\n/g' 2>/dev/null)

        if [ -n "$docker0Containers" ]; then
          if [ $fail -eq 0 ]; then
            info "$check_5_29"
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
              info "     * Container in docker0 network: $cName"
              docker_network_containers="$docker_network_containers $c:$cName"
            fi
          done
        fi
      currentScore=$((currentScore + 0))
    fi
  done
  # We went through all the containers and found none in docker0 network
  if [ $fail -eq 0 ]; then
      pass "$check_5_29"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "INFO" "Containers using docker0 network" "$docker_network_containers"
      currentScore=$((currentScore + 0))
  fi
}

# 5.30
check_5_30() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_30="5.30"
  desc_5_30="Ensure that the host's user namespaces are not shared (Scored)"
  check_5_30="$id_5_30  - $desc_5_30"
  starttestjson "$id_5_30" "$desc_5_30"

  totalChecks=$((totalChecks + 1))

  fail=0
  hostns_shared_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .HostConfig.UsernsMode }}' "$c" 2>/dev/null | grep -i 'host' >/dev/null 2>&1; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_30"
        warn "     * Namespace shared: $c"
        hostns_shared_containers="$hostns_shared_containers $c"
        fail=1
      else
        warn "     * Namespace shared: $c"
        hostns_shared_containers="$hostns_shared_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with host's user namespace shared
  if [ $fail -eq 0 ]; then
      pass "$check_5_30"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers sharing host user namespace" "$hostns_shared_containers"
      currentScore=$((currentScore - 1))
  fi
}

# 5.31
check_5_31() {
  if [ "$running_containers" -ne 1 ]; then
    return
  fi

  id_5_31="5.31"
  desc_5_31="Ensure that the Docker socket is not mounted inside any containers (Scored)"
  check_5_31="$id_5_31  - $desc_5_31"
  starttestjson "$id_5_31" "$desc_5_31"

  totalChecks=$((totalChecks + 1))

  fail=0
  docker_sock_containers=""
  for c in $containers; do
    if docker inspect --format '{{ .Mounts }}' "$c" 2>/dev/null | grep 'docker.sock' >/dev/null 2>&1; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_31"
        warn "     * Docker socket shared: $c"
        docker_sock_containers="$docker_sock_containers $c"
        fail=1
      else
        warn "     * Docker socket shared: $c"
        docker_sock_containers="$docker_sock_containers $c"
      fi
    fi
  done
  # We went through all the containers and found none with docker.sock shared
  if [ $fail -eq 0 ]; then
      pass "$check_5_31"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Containers sharing docker socket" "$docker_sock_containers"
      currentScore=$((currentScore - 1))
  fi
}

check_5_end() {
  endsectionjson
}
