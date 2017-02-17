#!/bin/sh

logit "\n"
info "4 - Container Images and Build Files"

# 4.1
check_4_1="4.1  - Create a user for the container"

# If container_users is empty, there are no running containers
if [ -z "$containers" ]; then
  info "$check_4_1"
  info "     * No containers running"
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
        fail=1
      else
        warn "     * Running as root: $c"
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

images=$(docker images -q)

# 4.2
check_4_2="4.2  - Use trusted base images for containers"
info "$check_4_2"

# 4.3
check_4_3="4.3  - Do not install unnecessary packages in the container"
info "$check_4_3"

# 4.4
check_4_4="4.4  - Scan and rebuild the images to include security patches"
info "$check_4_4"

# 4.5
check_4_5="4.5  - Enable Content trust for Docker"
if [ "x$DOCKER_CONTENT_TRUST" = "x1" ]; then
  pass "$check_4_5"
else
  warn "$check_4_5"
fi

# 4.6
check_4_6="4.6  - Add HEALTHCHECK instruction to the container image"
fail=0
for img in $images; do
  if docker inspect --format='{{.Config.Healthcheck}}' "$img" 2>/dev/null | grep -e "<nil>" >/dev/null 2>&1; then
    if [ $fail -eq 0 ]; then
      fail=1
      warn "$check_4_6"
    fi
    imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
    if ! [ "$imgName" = '[]' ]; then
      warn "     * No Healthcheck found: $imgName"
    fi
  fi
done
if [ $fail -eq 0 ]; then
  pass "$check_4_6"
fi

# 4.7
check_4_7="4.7  - Do not use update instructions alone in the Dockerfile"
fail=0
for img in $images; do
  if docker history "$img" 2>/dev/null | grep -e "update" >/dev/null 2>&1; then
    if [ $fail -eq 0 ]; then
      fail=1
      info "$check_4_7"
    fi
    imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
    if ! [ "$imgName" = '[]' ]; then
      info "     * Update instruction found: $imgName"
    fi
  fi
done
if [ $fail -eq 0 ]; then
  pass "$check_4_7"
fi

# 4.8
check_4_8="4.8  - Remove setuid and setgid permissions in the images"
info "$check_4_8"

# 4.9
check_4_9="4.9  - Use COPY instead of ADD in Dockerfile"
fail=0
for img in $images; do
  docker history "$img" 2> /dev/null | grep 'ADD' >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    if [ $fail -eq 0 ]; then
      fail=1
      info "$check_4_9"
    fi
    imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
    if ! [ "$imgName" = '[]' ]; then
      info "     * ADD in image history: $imgName"
    fi
  fi
done
if [ $fail -eq 0 ]; then
  pass "$check_4_9"
fi

# 4.10
check_4_10="4.10 - Do not store secrets in Dockerfiles"
info "$check_4_10"

# 4.11
check_4_11="4.11 - Install verified packages only"
info "$check_4_11"
