#!/bin/sh

logit "\n"
info "4 - Container Images and Build File"

# 4.1
check_4_1="4.1  - Ensure a user for the container has been created"

# If container_users is empty, there are no running containers
if [ -z "$containers" ]; then
  info "$check_4_1"
  info "     * No containers running"
  logjson "4.1" "INFO"
else
  # We have some containers running, set failure flag to 0. Check for Users.
  fail=0
  # Make the loop separator be a new-line in POSIX compliant fashion
  set -f; IFS=$'
'
  for c in $containers; do
    user=$(docker inspect --format 'User={{.Config.User}}' "$c")

    if [ "$user" = "User=" -o "$user" = "User=[]" -o "$user" = "User=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check_4_1"
        warn "     * Running as root: $c"
        logjson "4.1" "WARN: $c"
        fail=1
      else
        warn "     * Running as root: $c"
        logjson "4.1" "WARN: $c"
      fi
    fi
  done
  # We went through all the containers and found none running as root
  if [ $fail -eq 0 ]; then
      pass "$check_4_1"
      logjson "4.1" "PASS"
  fi
fi
# Make the loop separator go back to space
set +f; unset IFS

images=$(docker images -q)

# 4.2
check_4_2="4.2  - Ensure that containers use trusted base images"
note "$check_4_2"
logjson "4.2" "NOTE"

# 4.3
check_4_3="4.3  - Ensure unnecessary packages are not installed in the container"
note "$check_4_3"
logjson "4.3" "NOTE"

# 4.4
check_4_4="4.4  - Ensure images are scanned and rebuilt to include security patches"
note "$check_4_4"
logjson "4.4" "NOTE"

# 4.5
check_4_5="4.5  - Ensure Content trust for Docker is Enabled"
if [ "x$DOCKER_CONTENT_TRUST" = "x1" ]; then
  pass "$check_4_5"
  logjson "4.5" "PASS"
else
  warn "$check_4_5"
  logjson "4.5" "WARN"
fi

# 4.6
check_4_6="4.6  - Ensure HEALTHCHECK instructions have been added to the container image"
fail=0
for img in $images; do
  if docker inspect --format='{{.Config.Healthcheck}}' "$img" 2>/dev/null | grep -e "<nil>" >/dev/null 2>&1; then
    if [ $fail -eq 0 ]; then
      fail=1
      warn "$check_4_6"
      logjson "4.6" "WARN"
    fi
    imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
    if ! [ "$imgName" = '[]' ]; then
      warn "     * No Healthcheck found: $imgName"
      logjson "4.6" "WARN: $imgName"
    fi
  fi
done
if [ $fail -eq 0 ]; then
  pass "$check_4_6"
  logjson "4.6" "PASS"
fi

# 4.7
check_4_7="4.7  - Ensure update instructions are not use alone in the Dockerfile"
fail=0
for img in $images; do
  if docker history "$img" 2>/dev/null | grep -e "update" >/dev/null 2>&1; then
    if [ $fail -eq 0 ]; then
      fail=1
      info "$check_4_7"
      logjson "4.7" "INFO"
    fi
    imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
    if ! [ "$imgName" = '[]' ]; then
      info "     * Update instruction found: $imgName"
    fi
  fi
done
if [ $fail -eq 0 ]; then
  pass "$check_4_7"
  logjson "4.7" "PASS"
fi

# 4.8
check_4_8="4.8  - Ensure setuid and setgid permissions are removed in the images"
note "$check_4_8"
logjson "4.8" "NOTE"

# 4.9
check_4_9="4.9  - Ensure COPY is used instead of ADD in Dockerfile"
fail=0
for img in $images; do
  docker history "$img" 2> /dev/null | grep 'ADD' >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    if [ $fail -eq 0 ]; then
      fail=1
      info "$check_4_9"
      logjson "4.9" "INFO"
    fi
    imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
    if ! [ "$imgName" = '[]' ]; then
      info "     * ADD in image history: $imgName"
      logjson "4.9" "INFO: $imgName"
    fi
  fi
done
if [ $fail -eq 0 ]; then
  pass "$check_4_9"
  logjson "4.9" "PASS"
fi

# 4.10
check_4_10="4.10 - Ensure secrets are not stored in Dockerfiles"
note "$check_4_10"
logjson "4.10" "NOTE"

# 4.11
check_4_11="4.11 - Ensure verified packages are only Installed"
note "$check_4_11"
logjson "4.11" "NOTE"
