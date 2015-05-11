#!/bin/sh

logit "\n"
info "6  - Docker Security Operations"

# 6.5
check_6_5="6.5 - Use a centralized and remote log collection service"

containers=`docker ps -q`
# If containers is empty, there are no running containers
if test "$containers" = ""; then
  info "$check_6_5"
  info "     * No containers running"
else
  # List all the running containers, ouput their ID and host devices
  containers=`docker ps -q | xargs docker inspect --format '{{ .Id}}:{{ .Volumes }}'`
  # We have some containers running, set failure flag to 0.
  fail=0
  # Make the loop separator be a new-line in POSIX compliant fashion
  set -f; IFS=$'
'
  for c in $containers; do
    mode=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`
    if test $mode = "map[]"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_6_5"
        info "     * Container has no volumes, ensure centralized logging is enabled : $container_id"
        fail=1
      else
        info "     * Container has no volumes, ensure centralized logging is enabled : $container_id"
      fi
    fi
  done
  # Only alert if there are no volumes. If there are volumes, can't know if they
  # are used for logs
fi
# Make the loop separator go back to space
set +f; unset IFS

# 6.6
check_6_6="6.6 - Avoid image sprawl"
images=`docker images | wc -l | awk '{print $1}'`
if [ $images -gt 200 ]; then
  warn "$check_6_6"
  warn "     * There are currently: $images images"
else
  info "$check_6_6"
  info "     * There are currently: $images images"
fi

# 6.7
check_6_7="6.7 - Avoid container sprawl"
total_containers=`docker info 2>/dev/null | grep "Containers" | awk '{print $2}'`
running_containers=`docker ps -q | wc -l | awk '{print $1}'`
diff=`expr "$total_containers" - "$running_containers"`
if [ $diff -gt 25 ]; then
  warn "$check_6_7"
  warn "     * There are currently a total of $total_containers containers, with only $running_containers of them currently running"
else
  info "$check_6_7"
  info "     * There are currently a total of $total_containers containers, with $running_containers of them currently running"
fi
