#!/bin/sh

logit "\n"
info "5 - Container Runtime"

# If containers is empty, there are no running containers
if [ -z "$containers" ]; then
  info "     * No containers running, skipping Section 5"
else
  # Make the loop separator be a new-line in POSIX compliant fashion
  set -f; IFS=$'
'
  # 5.1
  check_5_1="5.1  - Do not disable AppArmor Profile"

  fail=0
  for c in $containers; do
    policy=$(docker inspect --format 'AppArmorProfile={{ .AppArmorProfile }}' "$c")

    if [ "$policy" = "AppArmorProfile=" -o "$policy" = "AppArmorProfile=[]" -o "$policy" = "AppArmorProfile=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_1"
        warn "     * No AppArmorProfile Found: $c"
        fail=1
      else
        warn "     * No AppArmorProfile Found: $c"
      fi
    fi
  done
  # We went through all the containers and found none without AppArmor
  if [ $fail -eq 0 ]; then
      pass "$check_5_1"
  fi

  # 5.2
  check_5_2="5.2  - Verify SELinux security options, if applicable"

  fail=0
  for c in $containers; do
    policy=$(docker inspect --format 'SecurityOpt={{ .HostConfig.SecurityOpt }}' "$c")

    if [ "$policy" = "SecurityOpt=" -o "$policy" = "SecurityOpt=[]" -o "$policy" = "SecurityOpt=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_2"
        warn "     * No SecurityOptions Found: $c"
        fail=1
      else
        warn "     * No SecurityOptions Found: $c"
      fi
    fi
  done
  # We went through all the containers and found none without SELinux
  if [ $fail -eq 0 ]; then
      pass "$check_5_2"
  fi

  # 5.3
  check_5_3="5.3  - Restrict Linux Kernel Capabilities within containers"

  fail=0
  for c in $containers; do
    container_caps=$(docker inspect --format 'CapAdd={{ .HostConfig.CapAdd}}' "$c")
    caps=$(echo "$container_caps" | tr "[:lower:]" "[:upper:]" | \
      sed 's/CAPADD/CapAdd/' | \
      sed -r "s/AUDIT_WRITE|CHOWN|DAC_OVERRIDE|FOWNER|FSETID|KILL|MKNOD|NET_BIND_SERVICE|NET_RAW|SETFCAP|SETGID|SETPCAP|SETUID|SYS_CHROOT|\s//g")

    if [ "$caps" != 'CapAdd=' -a "$caps" != 'CapAdd=[]' -a "$caps" != 'CapAdd=<no value>' -a "$caps" != 'CapAdd=<nil>' ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_3"
        warn "     * Capabilities added: $caps to $c"
        fail=1
      else
        warn "     * Capabilities added: $caps to $c"
      fi
    fi
  done
  # We went through all the containers and found none with extra capabilities
  if [ $fail -eq 0 ]; then
      pass "$check_5_3"
  fi

  # 5.4
  check_5_4="5.4  - Do not use privileged containers"

  fail=0
  for c in $containers; do
    privileged=$(docker inspect --format '{{ .HostConfig.Privileged }}' "$c")

    if [ "$privileged" = "true" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_4"
        warn "     * Container running in Privileged mode: $c"
        fail=1
      else
        warn "     * Container running in Privileged mode: $c"
      fi
    fi
  done
  # We went through all the containers and found no privileged containers
  if [ $fail -eq 0 ]; then
      pass "$check_5_4"
  fi

  # 5.5
  check_5_5="5.5  - Do not mount sensitive host system directories on containers"

  # List of sensitive directories to test for. Script uses new-lines as a separator.
  # Note the lack of identation. It needs it for the substring comparison.
  sensitive_dirs='/boot
/dev
/etc
/lib
/proc
/sys
/usr'
  fail=0
  for c in $containers; do
    if docker inspect --format '{{ .VolumesRW }}' "$c" 2>/dev/null 1>&2; then
      volumes=$(docker inspect --format '{{ .VolumesRW }}' "$c")
    else
      volumes=$(docker inspect --format '{{ .Mounts }}' "$c")
    fi
    # Go over each directory in sensitive dir and see if they exist in the volumes
    for v in $sensitive_dirs; do
      sensitive=0
      contains "$volumes" "$v" && sensitive=1
      if [ $sensitive -eq 1 ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_5_5"
          warn "     * Sensitive directory $v mounted in: $c"
          fail=1
        else
          warn "     * Sensitive directory $v mounted in: $c"
        fi
      fi
    done
  done
  # We went through all the containers and found none with sensitive mounts
  if [ $fail -eq 0 ]; then
      pass "$check_5_5"
  fi

  # 5.6
  check_5_6="5.6  - Do not run ssh within containers"

  fail=0
  printcheck=0
  for c in $containers; do

    processes=$(docker exec "$c" ps -el 2>/dev/null | grep -c sshd | awk '{print $1}')
    if [ "$processes" -ge 1 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_6"
        warn "     * Container running sshd: $c"
        fail=1
	printcheck=1
      else
        warn "     * Container running sshd: $c"
      fi
    fi

    exec_check=$(docker exec "$c" ps -el 2>/dev/null)
    if [ $? -eq 255 ]; then
        if [ $printcheck -eq 0 ]; then
          warn "$check_5_6"
	  printcheck=1
        fi
      warn "     * Docker exec fails: $c"
      fail=1
    fi

  done
  # We went through all the containers and found none with sshd
  if [ $fail -eq 0 ]; then
      pass "$check_5_6"
  fi

  # 5.7
  check_5_7="5.7  - Do not map privileged ports within containers"

  fail=0
  for c in $containers; do
    # Port format is private port -> ip: public port
    ports=$(docker port "$c" | awk '{print $0}' | cut -d ':' -f2)

    # iterate through port range (line delimited)
    for port in $ports; do
    if [ ! -z "$port" ] && [ "0$port" -lt 1024 ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_5_7"
          warn "     * Privileged Port in use: $port in $c"
          fail=1
        else
          warn "     * Privileged Port in use: $port in $c"
        fi
      fi
    done
  done
  # We went through all the containers and found no privileged ports
  if [ $fail -eq 0 ]; then
      pass "$check_5_7"
  fi

  # 5.8
  check_5_8="5.8  - Open only needed ports on container"
  info "$check_5_8"

  # 5.9
  check_5_9="5.9  - Do not share the host's network namespace"

  fail=0
  for c in $containers; do
    mode=$(docker inspect --format 'NetworkMode={{ .HostConfig.NetworkMode }}' "$c")

    if [ "$mode" = "NetworkMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_9"
        warn "     * Container running with networking mode 'host': $c"
        fail=1
      else
        warn "     * Container running with networking mode 'host': $c"
      fi
    fi
  done
  # We went through all the containers and found no Network Mode host
  if [ $fail -eq 0 ]; then
      pass "$check_5_9"
  fi

  # 5.10
  check_5_10="5.10 - Limit memory usage for container"

  fail=0
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
        fail=1
      else
        warn "     * Container running without memory restrictions: $c"
      fi
    fi
  done
  # We went through all the containers and found no lack of Memory restrictions
  if [ $fail -eq 0 ]; then
      pass "$check_5_10"
  fi

  # 5.11
  check_5_11="5.11 - Set container CPU priority appropriately"

  fail=0
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
        fail=1
      else
        warn "     * Container running without CPU restrictions: $c"
      fi
    fi
  done
  # We went through all the containers and found no lack of CPUShare restrictions
  if [ $fail -eq 0 ]; then
      pass "$check_5_11"
  fi

  # 5.12
  check_5_12="5.12 - Mount container's root filesystem as read only"

  fail=0
  for c in $containers; do
   read_status=$(docker inspect --format '{{ .HostConfig.ReadonlyRootfs }}' "$c")

    if [ "$read_status" = "false" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_12"
        warn "     * Container running with root FS mounted R/W: $c"
        fail=1
      else
        warn "     * Container running with root FS mounted R/W: $c"
      fi
    fi
  done
  # We went through all the containers and found no R/W FS mounts
  if [ $fail -eq 0 ]; then
      pass "$check_5_12"
  fi

  # 5.13
  check_5_13="5.13 - Bind incoming container traffic to a specific host interface"

  fail=0
  for c in $containers; do
    for ip in $(docker port "$c" | awk '{print $3}' | cut -d ':' -f1); do
      if [ "$ip" = "0.0.0.0" ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_5_13"
          warn "     * Port being bound to wildcard IP: $ip in $c"
          fail=1
        else
          warn "     * Port being bound to wildcard IP: $ip in $c"
        fi
      fi
    done
  done
  # We went through all the containers and found no ports bound to 0.0.0.0
  if [ $fail -eq 0 ]; then
      pass "$check_5_13"
  fi

  # 5.14
  check_5_14="5.14 - Set the 'on-failure' container restart policy to 5"

  fail=0
  for c in $containers; do
    policy=$(docker inspect --format MaximumRetryCount='{{ .HostConfig.RestartPolicy.MaximumRetryCount }}' "$c")

    if [ "$policy" != "MaximumRetryCount=5" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_14"
        warn "     * MaximumRetryCount is not set to 5: $c"
        fail=1
      else
        warn "     * MaximumRetryCount is not set to 5: $c"
      fi
    fi
  done
  # We went through all the containers and they all had MaximumRetryCount=5
  if [ $fail -eq 0 ]; then
      pass "$check_5_14"
  fi

  # 5.15
  check_5_15="5.15 - Do not share the host's process namespace"

  fail=0
  for c in $containers; do
    mode=$(docker inspect --format 'PidMode={{.HostConfig.PidMode }}' "$c")

    if [ "$mode" = "PidMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_15"
        warn "     * Host PID namespace being shared with: $c"
        fail=1
      else
        warn "     * Host PID namespace being shared with: $c"
      fi
    fi
  done
  # We went through all the containers and found none with PidMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_15"
  fi

  # 5.16
  check_5_16="5.16 - Do not share the host's IPC namespace"

  fail=0
  for c in $containers; do
    mode=$(docker inspect --format 'IpcMode={{.HostConfig.IpcMode }}' "$c")

    if [ "$mode" = "IpcMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_16"
        warn "     * Host IPC namespace being shared with: $c"
        fail=1
      else
        warn "     * Host IPC namespace being shared with: $c"
      fi
    fi
  done
  # We went through all the containers and found none with IPCMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_16"
  fi

  # 5.17
  check_5_17="5.17 - Do not directly expose host devices to containers"

  fail=0
  for c in $containers; do
    devices=$(docker inspect --format 'Devices={{ .HostConfig.Devices }}' "$c")

    if [ "$devices" != "Devices=" -a "$devices" != "Devices=[]" -a "$devices" != "Devices=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_5_17"
        info "     * Container has devices exposed directly: $c"
        fail=1
      else
        info "     * Container has devices exposed directly: $c"
      fi
    fi
  done
  # We went through all the containers and found none with devices
  if [ $fail -eq 0 ]; then
      pass "$check_5_17"
  fi

  # 5.18
  check_5_18="5.18 - Override default ulimit at runtime only if needed"

  fail=0
  for c in $containers; do
    ulimits=$(docker inspect --format 'Ulimits={{ .HostConfig.Ulimits }}' "$c")

    if [ "$ulimits" = "Ulimits=" -o "$ulimits" = "Ulimits=[]" -o "$ulimits" = "Ulimits=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_5_18"
        info "     * Container no default ulimit override: $c"
        fail=1
      else
        info "     * Container no default ulimit override: $c"
      fi
    fi
  done
  # We went through all the containers and found none without Ulimits
  if [ $fail -eq 0 ]; then
      pass "$check_5_18"
  fi

  # 5.19
  check_5_19="5.19 - Do not set mount propagation mode to shared"

  fail=0
  for c in $containers; do
    if docker inspect --format 'Propagation={{range $mnt := .Mounts}} {{json $mnt.Propagation}} {{end}}' "$c" | \
     grep shared 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_19"
        warn "     * Mount propagation mode is shared: $c"
        fail=1
      else
        warn "     * Mount propagation mode is shared: $c"
      fi
    fi
  done
  # We went through all the containers and found none with shared propagation mode
 if [ $fail -eq 0 ]; then
      pass "$check_5_19"
  fi

  # 5.20
  check_5_20="5.20 - Do not share the host's UTS namespace"

  fail=0
  for c in $containers; do
    mode=$(docker inspect --format 'UTSMode={{.HostConfig.UTSMode }}' "$c")

    if [ "$mode" = "UTSMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_20"
        warn "     * Host UTS namespace being shared with: $c"
        fail=1
      else
        warn "     * Host UTS namespace being shared with: $c"
      fi
    fi
  done
  # We went through all the containers and found none with UTSMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_20"
  fi

  # 5.21
  check_5_21="5.21 - Do not disable default seccomp profile"

  fail=0
  for c in $containers; do
    if docker inspect --format 'SecurityOpt={{.HostConfig.SecurityOpt }}' "$c" | grep 'seccomp:unconfined' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_21"
        warn "     * Default seccomp profile disabled: $c"
        fail=1
      else
        warn "     * Default seccomp profile disabled: $c"
      fi
    fi
  done
  # We went through all the containers and found none with default secomp profile disabled
  if [ $fail -eq 0 ]; then
      pass "$check_5_21"
  fi

  # 5.22
  check_5_22="5.22 - Do not docker exec commands with privileged option"
  info "$check_5_22"

  # 5.23
  check_5_23="5.23 - Do not docker exec commands with user option"
  info "$check_5_23"

  # 5.24
  check_5_24="5.24 - Confirm cgroup usage"

  fail=0
  for c in $containers; do
    mode=$(docker inspect --format 'CgroupParent={{.HostConfig.CgroupParent }}x' "$c")

    if [ "$mode" != "CgroupParent=x" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_24"
        warn "     * Confirm cgroup usage: $c"
        fail=1
      else
        warn "     * Confirm cgroup usage: $c"
      fi
    fi
  done
  # We went through all the containers and found none with UTSMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_24"
  fi

  # 5.25
  check_5_25="5.25 - Restrict container from acquiring additional privileges"

  fail=0
  for c in $containers; do
    docker inspect --format 'SecurityOpt={{.HostConfig.SecurityOpt }}' "$c" | grep 'no-new-privileges' 2>/dev/null 1>&2

    if [ $? -ne 0 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_25"
        warn "     * Privileges not restricted: $c"
        fail=1
      else
        warn "     * Privileges not restricted: $c"
      fi
    fi
  done
  # We went through all the containers and found none with capability to acquire additional privileges
  if [ $fail -eq 0 ]; then
      pass "$check_5_25"
  fi

  # 5.26
  check_5_26="5.26 - Check container health at runtime"

  fail=0
  for c in $containers; do
    if ! docker inspect --format '{{ .Id }}: Health={{ .State.Health.Status }}' "$c" 2>/dev/null 1>&2; then
      if [ $fail -eq 0 ]; then
        warn "$check_5_26"
        warn "     * Health check not set: $c"
        fail=1
      else
        warn "     * Health check not set: $c"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
      pass "$check_5_26"
  fi

  # 5.27
  check_5_27="5.27 - Ensure docker commands always get the latest version of the image"
  info "$check_5_27"

  # 5.28
  check_5_28="5.28 - Use PIDs cgroup limit"

  fail=0
  for c in $containers; do
    pidslimit=$(docker inspect --format '{{.HostConfig.PidsLimit }}' "$c")

    if [ "$pidslimit" -le 0 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_28"
        warn "     * PIDs limit not set: $c"
        fail=1
      else
        warn "     * PIDs limit not set: $c"
      fi
    fi
  done
  # We went through all the containers and found all with PIDs limit
  if [ $fail -eq 0 ]; then
      pass "$check_5_28"
  fi

  # 5.29
  check_5_29="5.29 - Do not use Docker's default bridge docker0"

  fail=0
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
	  cName=$(docker inspect --format '{{.Name}}' "$c" 2>/dev/null | sed 's/\///g')
          info "     * Container in docker0 network: $cName"
        done
      fi
    fi
  done
  # We went through all the containers and found none in docker0 network
  if [ $fail -eq 0 ]; then
      pass "$check_5_29"
  fi

  # 5.30
  check_5_30="5.30 - Do not share the host's user namespaces"

  fail=0
  for c in $containers; do
    if docker inspect --format '{{ .HostConfig.UsernsMode }}' "$c" 2>/dev/null | grep -i 'host' >/dev/null 2>&1; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_30"
        warn "     * Namespace shared: $c"
        fail=1
      else
        warn "     * Namespace shared: $c"
      fi
    fi
  done
  # We went through all the containers and found none with host's user namespace shared
  if [ $fail -eq 0 ]; then
      pass "$check_5_30"
  fi

  # 5.31
  check_5_31="5.31 - Do not mount the Docker socket inside any containers"

  fail=0
  for c in $containers; do
    if docker inspect --format '{{ .Mounts }}' "$c" 2>/dev/null | grep 'docker.sock' >/dev/null 2>&1; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_31"
        warn "     * Docker socket shared: $c"
        fail=1
      else
        warn "     * Docker socket shared: $c"
      fi
    fi
  done
  # We went through all the containers and found none with docker.sock shared
  if [ $fail -eq 0 ]; then
      pass "$check_5_31"
  fi
fi
