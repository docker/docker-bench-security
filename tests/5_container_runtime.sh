#!/bin/sh

logit "\n"
info "5  - Container Runtime"

# If containers is empty, there are no running containers
if test "$containers" = ""; then
  info "     * No containers running, skipping Section 5"
else
  # List all running containers
  containers=`docker ps -q`
  # Make the loop separator be a new-line in POSIX compliant fashion
  set -f; IFS=$'
'
  # 5.1
  check_5_1="5.1  - Verify AppArmor Profile, if applicable"

  # List all the running containers, ouput their ID and AppArmorProfile
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:AppArmorProfile={{.AppArmorProfile }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    policy=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`

    if test $policy = "AppArmorProfile=" || test $policy = "AppArmorProfile=<no value>"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_1"
        warn "     * No AppArmorProfile Found: $container_id"
        fail=1
      else
        warn "     * No AppArmorProfile Found: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none without AppArmor
  if [ $fail -eq 0 ]; then
      pass "$check_5_1"
  fi

  # 5.2
  check_5_2="5.2  - Verify SELinux security options, if applicable"

  # List all the running containers, ouput their ID and SecurityOptions
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:SecurityOpt={{.HostConfig.SecurityOpt }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    policy=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`

    if test $policy = "SecurityOpt=" || test $policy = "SecurityOpt=<no value>"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_2"
        warn "     * No SecurityOptions Found: $container_id"
        fail=1
      else
        warn "     * No SecurityOptions Found: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none without SELinux
  if [ $fail -eq 0 ]; then
      pass "$check_5_2"
  fi

  # 5.3
  check_5_3="5.3  - Verify that containers are running only a single main process"

  # List all the running containers, ouput their Id
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0

  for c in $cont_inspect; do
    processes=`docker exec $c ps -el 2>/dev/null | wc -l | awk '{print $1}'`
    if [ $processes -gt 5 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_3"
        warn "     * Too many proccesses running: $container_id"
        fail=1
      else
        warn "     * Too many proccesses running: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none with toom any processes
  if [ $fail -eq 0 ]; then
      pass "$check_5_3"
  fi

  # 5.4
  check_5_4="5.4  - Restrict Linux Kernel Capabilities within containers"

  # List all the running containers, ouput their ID and CapAdd
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:CapAdd={{ .HostConfig.CapAdd}}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0

  for c in $cont_inspect; do
    caps=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $caps != "CapAdd=" && test $caps != "CapAdd=<no value>"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_4"
        warn "     * Capabilities added: $caps to $container_id"
        fail=1
      else
        warn "     * Capabilities added: $caps to $container_id"
      fi
    fi
  done
  # We went through all the containers and found none with extra capabilities
  if [ $fail -eq 0 ]; then
      pass "$check_5_4"
  fi

  # 5.5
  check_5_5="5.5  - Do not use privileged containers"

  # List all the running containers, ouput their ID and privileged status
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:{{.HostConfig.Privileged }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0

  for c in $cont_inspect; do
    privileged=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $privileged = "true"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_5"
        warn "     * Container running in Privileged mode: $container_id"
        fail=1
      else
        warn "     * Container running in Privileged mode: $container_id"
      fi
    fi
  done
  # We went through all the containers and found no privileged containers
  if [ $fail -eq 0 ]; then
      pass "$check_5_5"
  fi

  # 5.6
  check_5_6="5.6  - Do not mount sensitive host system directories on containers"

  containers=`docker ps -q`
  # List of sensitive directories to test for. Script uses new-lines as a separator
  sensitive_dirs='/boot
  /dev
  /etc
  /lib
  /proc
  /sys
  /usr'
  # List all the running containers, ouput their ID and R/W Volumes
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:{{ .VolumesRW }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    volumes=`printf "$c" | cut -d ":" -f 2-`
    container_id=`printf "$c" | cut -d ":" -f 1`
    sensitive=0

    # Go over each directory in sensitive dir and see if they exist in the volumes
    for v in $sensitive_dirs; do
      if [ $sensitive -eq 0 ]; then
        contains "$volumes" "$v:" && sensitive=1
      fi
    done

    if [ $sensitive -eq 1 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_6"
        warn "     * Container mounted with sensitive directory: $container_id"
        fail=1
      else
        warn "     * Container mounted with sensitive directory: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none with sensitive mounts
  if [ $fail -eq 0 ]; then
      pass "$check_5_6"
  fi

  # 5.7
  check_5_7="5.7  - Do not run ssh within containers"

  # List all the running containers, ouput their Id
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    processes=`docker exec $c ps -el 2>/dev/null | grep sshd | wc -l | awk '{print $1}'`
    if [ $processes -gt 1 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_7"
        warn "     * Container running sshd: $container_id"
        fail=1
      else
        warn "     * Container running sshd: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none with sshd
  if [ $fail -eq 0 ]; then
      pass "$check_5_7"
  fi

  # 5.8
  check_5_8="5.8  - Do not map privileged ports within containers"

  # List all the running containers, ouput their listening ports
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $containers; do
    port=`docker port $c | awk '{print $1}' | cut -d '/' -f1`
    if test "$port" != "" && [ $port -lt 1025 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_8"
        warn "     * Privileged Port in use: $port"
        fail=1
      else
        warn "     * Privileged Port in use: $port"
      fi
    fi
  done
  # We went through all the containers and found no privileged ports
  if [ $fail -eq 0 ]; then
      pass "$check_5_8"
  fi

  # 5.10
  check_5_10="5.10 - Do not use host network mode on container"

  # List all the running containers, ouput their ID and network mode
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:NetworkMode={{.HostConfig.NetworkMode }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    mode=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $mode = "NetworkMode=host"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_10"
        warn "     * Container running with networking mode 'host': $container_id"
        fail=1
      else
        warn "     * Container running with networking mode 'host': $container_id"
      fi
    fi
  done
  # We went through all the containers and found no Network Mode host
  if [ $fail -eq 0 ]; then
      pass "$check_5_10"
  fi

  # 5.11
  check_5_11="5.11 - Limit memory usage for container"

  # List all the running containers, ouput their ID and memory limit
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:{{ .Config.Memory }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  # Make the loop separator be a new-line in POSIX compliant fashion
  for c in $cont_inspect; do
    memory=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $memory = "0"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_11"
        warn "     * Container running without memory restrictions: $container_id"
        fail=1
      else
        warn "     * Container running without memory restrictions: $container_id"
      fi
    fi
  done
  # We went through all the containers and found no lack of Memory restrictions
  if [ $fail -eq 0 ]; then
      pass "$check_5_11"
  fi

  # 5.12
  check_5_12="5.12 - Set container CPU priority appropriately"

  # List all the running containers, ouput their ID and CPU Shares
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:{{.Config.CpuShares }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    shares=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $shares = "0"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_12"
        warn "     * Container running without CPU restrictions: $container_id"
        fail=1
      else
        warn "     * Container running without CPU restrictions: $container_id"
      fi
    fi
  done
  # We went through all the containers and found no lack of CPUShare restrictions
  if [ $fail -eq 0 ]; then
      pass "$check_5_12"
  fi

  # 5.13
  check_5_13="5.13 - Mount container's root filesystem as read only"

  # List all the running containers, ouput their ID and status of ReadonlyRootfs
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:{{.HostConfig.ReadonlyRootfs }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    read_status=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $read_status = "false"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_13"
        warn "     * Container running with root FS mounted R/W: $container_id"
        fail=1
      else
        warn "     * Container running with root FS mounted R/W: $container_id"
      fi
    fi
  done
  # We went through all the containers and found no R/W FS mounts
  if [ $fail -eq 0 ]; then
      pass "$check_5_13"
  fi

  # 5.14
  check_5_14="5.14 - Bind incoming container traffic to a specific host interface"

  # List all the running containers, ouput the IP where ports are being bound
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $containers; do
    ip=`docker port $c | awk '{print $3}' | cut -d ':' -f1`
    if test "$ip" = "0.0.0.0"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_14"
        warn "     * Port being bound to wildcard IP: 0.0.0.0"
        fail=1
      else
        warn "     * Port being bound to wildcard IP: 0.0.0.0"
      fi
    fi
  done
  # We went through all the containers and found no ports bound to 0.0.0.0
  if [ $fail -eq 0 ]; then
      pass "$check_5_14"
  fi

  # 5.15
  check_5_15="5.15 - Do not set the 'on-failure' container restart policy to always"

  # List all the running containers, ouput their ID and Restart Policy Name
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:RestartPolicyName={{.HostConfig.RestartPolicy.Name }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    policy=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`

    if test $policy = "RestartPolicyName=always"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_15"
        warn "     * Restart Policy set to always: $container_id"
        fail=1
      else
        warn "     * Restart Policy set to always: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none with restart policy always
  if [ $fail -eq 0 ]; then
      pass "$check_5_15"
  fi

  # 5.16
  check_5_16="5.16 - Do not share the host's process namespace"

  # List all the running containers, ouput their ID and PidMode
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:PidMode={{.HostConfig.PidMode }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    mode=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $mode = "PidMode=host"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_16"
        warn "     * Host PID namespace being shared with: $container_id"
        fail=1
      else
        warn "     * Host PID namespace being shared with: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none with PidMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_16"
  fi

  # 5.17
  check_5_17="5.17 - Do not share the host's IPC namespace"

  # List all the running containers, ouput their ID and IpcMode
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:IpcMode={{.HostConfig.IpcMode }}'`
  # We have some containers running, set failure flag to 0, set failure flag to 0
  fail=0
  for c in $cont_inspect; do
    mode=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $mode = "IpcMode=host"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_5_17"
        warn "     * Host IPC namespace being shared with: $container_id"
        fail=1
      else
        warn "     * Host IPC namespace being shared with: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none with IPCMode as host
  if [ $fail -eq 0 ]; then
      pass "$check_5_17"
  fi

  # 5.18
  check_5_18="5.18 - Do not directly expose host devices to containers"

  # List all the running containers, ouput their ID and host devices
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:Devices={{.HostConfig.Devices }}'`
  fail=0
  for c in $cont_inspect; do
    mode=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $mode != "Devices=[]" && test $mode != "Devices=<no value>"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_5_18"
        info "     * Container has devices exposed directly: $container_id"
        fail=1
      else
        info "     * Container has devices exposed directly: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none with devices
  if [ $fail -eq 0 ]; then
      pass "$check_5_18"
  fi

  # 5.19
  check_5_19="5.19 - Override default ulimit at runtime only if needed"

  # List all the running containers, ouput their ID and host devices
  cont_inspect=`docker ps -q | xargs docker inspect --format '{{ .Id }}:Ulimits={{.HostConfig.Ulimits }}'`
  fail=0
  for c in $cont_inspect; do
    mode=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $mode = "Ulimits=" || test $mode = "Ulimits=<no value>"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_5_19"
        info "     * Container no default ulimit override: $container_id"
        fail=1
      else
        info "     * Container no default ulimit override: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none without Ulimits
  if [ $fail -eq 0 ]; then
      pass "$check_5_19"
  fi
fi
