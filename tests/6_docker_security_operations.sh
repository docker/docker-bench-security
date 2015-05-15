#!/bin/sh

logit "\n"
info "6  - Docker Security Operations"

# 6.5
check_6_5="6.5 - Use a centralized and remote log collection service"

# If containers is empty, there are no running containers
if [ -z "$containers" ]; then
  info "$check_6_5"
  info "     * No containers running"
else
  fail=0
  set -f; IFS=$'
'
  for c in $containers; do
    volumes=`docker inspect --format '{{ .Volumes }}' $c`

    if [ "$volumes" = "map[]" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        info "$check_6_5"
        info "     * Container has no volumes, ensure centralized logging is enabled : $c"
        fail=1
      else
        info "     * Container has no volumes, ensure centralized logging is enabled : $c"
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
if [ $images -gt 100 ]; then
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
