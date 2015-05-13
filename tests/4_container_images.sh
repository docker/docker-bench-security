#!/bin/sh

logit "\n"
info "4 - Container Images and Build Files"

# 4.1
check_4_1="4.1  - Create a user for the container"

containers=`docker ps -q`
# If container_users is empty, there are no running containers
if test "$containers" = ""; then
  info "$check_4_1"
  info "     * No containers running"
else
  # List all the running containers, ouput their ID and USER
  containers=`docker ps -q | xargs docker inspect --format '{{ .Id }}:User={{.Config.User}}' 2>/dev/null`
  # We have some containers running, set failure flag to 0. Check for Users.
  fail=0
  # Make the loop separator be a new-line in POSIX compliant fashion
  set -f; IFS=$'
'
  for c in $containers; do
    user=`printf "$c" | cut -d ":" -f 2`
    container_id=`printf "$c" | cut -d ":" -f 1`

    if test $user = "User=" || test $user = "User=[]" ||test $user = "User=<no value>"; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_4_1"
        warn "     * Running as root: $container_id"
        fail=1
      else
        warn "     * Running as root: $container_id"
      fi
    fi
  done
  # We went through all the containers and found none running as root
  if [ $fail -eq 0 ]; then
      pass "$check_4_1"
  fi
fi
# Make the loop separator go back to space
set +f; unset IFS
