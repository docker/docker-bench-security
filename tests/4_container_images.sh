#!/bin/sh

check_4() {
  logit "\n"
  id_4="4"
  desc_4="Container Images and Build File"
  check_4="$id_4 - $desc_4"
  info "$check_4"
  startsectionjson "$id_4" "$desc_4"
}

# 4.1
check_4_1() {
  id_4_1="4.1"
  desc_4_1="Ensure that a user for the container has been created (Scored)"
  check_4_1="$id_4_1  - $desc_4_1"
  starttestjson "$id_4_1" "$desc_4_1"

  totalChecks=$((totalChecks + 1))

  # If container_users is empty, there are no running containers
  if [ -z "$containers" ]; then
    info "$check_4_1"
    info "     * No containers running"
    resulttestjson "INFO" "No containers running"
    currentScore=$((currentScore + 0))
  else
    # We have some containers running, set failure flag to 0. Check for Users.
    fail=0
    # Make the loop separator be a new-line in POSIX compliant fashion
    set -f; IFS=$'
  '
    root_containers=""
    for c in $containers; do
      user=$(docker inspect --format 'User={{.Config.User}}' "$c")

      if [ "$user" = "User=0" ] || [ "$user" = "User=root" ] || [ "$user" = "User=" ] || [ "$user" = "User=[]" ] || [ "$user" = "User=<no value>" ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_4_1"
          warn "     * Running as root: $c"
          root_containers="$root_containers $c"
          fail=1
        else
          warn "     * Running as root: $c"
          root_containers="$root_containers $c"
        fi
      fi
    done
    # We went through all the containers and found none running as root
    if [ $fail -eq 0 ]; then
        pass "$check_4_1"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
    else
        resulttestjson "WARN" "running as root" "$root_containers"
        currentScore=$((currentScore - 1))
    fi
  fi
  # Make the loop separator go back to space
  set +f; unset IFS
}

# 4.2
check_4_2() {
  id_4_2="4.2"
  desc_4_2="Ensure that containers use only trusted base images (Not Scored)"
  check_4_2="$id_4_2  - $desc_4_2"
  starttestjson "$id_4_2" "$desc_4_2"

  totalChecks=$((totalChecks + 1))
  note "$check_4_2"
  resulttestjson "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.3
check_4_3() {
  id_4_3="4.3"
  desc_4_3="Ensure that unnecessary packages are not installed in the container (Not Scored)"
  check_4_3="$id_4_3  - $desc_4_3"
  starttestjson "$id_4_3" "$desc_4_3"

  totalChecks=$((totalChecks + 1))
  note "$check_4_3"
  resulttestjson "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.4
check_4_4() {
  id_4_4="4.4"
  desc_4_4="Ensure images are scanned and rebuilt to include security patches (Not Scored)"
  check_4_4="$id_4_4  - $desc_4_4"
  starttestjson "$id_4_4" "$desc_4_4"

  totalChecks=$((totalChecks + 1))
  note "$check_4_4"
  resulttestjson "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.5
check_4_5() {
  id_4_5="4.5"
  desc_4_5="Ensure Content trust for Docker is Enabled (Scored)"
  check_4_5="$id_4_5  - $desc_4_5"
  starttestjson "$id_4_5" "$desc_4_5"

  totalChecks=$((totalChecks + 1))
  if [ "x$DOCKER_CONTENT_TRUST" = "x1" ]; then
    pass "$check_4_5"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_4_5"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 4.6
check_4_6() {
  id_4_6="4.6"
  desc_4_6="Ensure that HEALTHCHECK instructions have been added to container images (Scored)"
  check_4_6="$id_4_6  - $desc_4_6"
  starttestjson "$id_4_6" "$desc_4_6"

  totalChecks=$((totalChecks + 1))
  fail=0
  no_health_images=""
  for img in $images; do
    if docker inspect --format='{{.Config.Healthcheck}}' "$img" 2>/dev/null | grep -e "<nil>" >/dev/null 2>&1; then
      if [ $fail -eq 0 ]; then
        fail=1
        warn "$check_4_6"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        warn "     * No Healthcheck found: $imgName"
        no_health_images="$no_health_images $imgName"
      else
        warn "     * No Healthcheck found: $img"
        no_health_images="$no_health_images $img"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
    pass "$check_4_6"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    resulttestjson "WARN" "Images w/o HEALTHCHECK" "$no_health_images"
    currentScore=$((currentScore - 1))
  fi
}

# 4.7
check_4_7() {
  id_4_7="4.7"
  desc_4_7="Ensure update instructions are not use alone in the Dockerfile (Not Scored)"
  check_4_7="$id_4_7  - $desc_4_7"
  starttestjson "$id_4_7" "$desc_4_7"

  totalChecks=$((totalChecks + 1))
  fail=0
  update_images=""
  for img in $images; do
    if docker history "$img" 2>/dev/null | grep -e "update" >/dev/null 2>&1; then
      if [ $fail -eq 0 ]; then
        fail=1
        info "$check_4_7"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        info "     * Update instruction found: $imgName"
        update_images="$update_images $imgName"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
    pass "$check_4_7"
    resulttestjson "PASS"
    currentScore=$((currentScore + 0))
  else
    resulttestjson "INFO" "Update instructions found" "$update_images"
    currentScore=$((currentScore + 0))
  fi
}

# 4.8
check_4_8() {
  id_4_8="4.8"
  desc_4_8="Ensure setuid and setgid permissions are removed (Not Scored)"
  check_4_8="$id_4_8  - $desc_4_8"
  starttestjson "$id_4_8" "$desc_4_8"

  totalChecks=$((totalChecks + 1))
  note "$check_4_8"
  resulttestjson "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.9
check_4_9() {
  id_4_9="4.9"
  desc_4_9="Ensure that COPY is used instead of ADD in Dockerfiles (Not Scored)"
  check_4_9="$id_4_9  - $desc_4_9"
  starttestjson "$id_4_9" "$desc_4_9"

  totalChecks=$((totalChecks + 1))
  fail=0
  add_images=""
  for img in $images; do
    if docker history --format "{{ .CreatedBy }}" --no-trunc "$img" | \
      sed '$d' | grep -q 'ADD'; then
      if [ $fail -eq 0 ]; then
        fail=1
        info "$check_4_9"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        info "     * ADD in image history: $imgName"
        add_images="$add_images $imgName"
      fi
      currentScore=$((currentScore + 0))
    fi
  done
  if [ $fail -eq 0 ]; then
    pass "$check_4_9"
    resulttestjson "PASS"
    currentScore=$((currentScore + 0))
  else
    resulttestjson "INFO" "Images using ADD" "$add_images"
  fi
}

# 4.10
check_4_10() {
  id_4_10="4.10"
  desc_4_10="Ensure secrets are not stored in Dockerfiles (Not Scored)"
  check_4_10="$id_4_10  - $desc_4_10"
  starttestjson "$id_4_10" "$desc_4_10"

  totalChecks=$((totalChecks + 1))
  note "$check_4_10"
  resulttestjson "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.11
check_4_11() {
  id_4_11="4.11"
  desc_4_11="Ensure only verified packages are are installed (Not Scored)"
  check_4_11="$id_4_11  - $desc_4_11"
  starttestjson "$id_4_11" "$desc_4_11"

  totalChecks=$((totalChecks + 1))
  note "$check_4_11"
  resulttestjson "NOTE"
  currentScore=$((currentScore + 0))
}

check_4_end() {
  endsectionjson
}
