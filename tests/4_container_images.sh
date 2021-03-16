#!/bin/sh

check_4() {
  logit ""
  local id="4"
  local desc="Container Images and Build File"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_4_1() {
  local id="4.1"
  local desc="Ensure that a user for the container has been created (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  # If container_users is empty, there are no running containers
  if [ -z "$containers" ]; then
    info -c "$check"
    info "     * No containers running"
    logcheckresult "INFO" "No containers running"
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
          warn -s "$check"
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
        pass -s "$check"
        logcheckresult "PASS"
    else
        logcheckresult "WARN" "running as root" "$root_containers"
    fi
  fi
  # Make the loop separator go back to space
  set +f; unset IFS
}

check_4_2() {
  local id="4.2"
  local desc="Ensure that containers use only trusted base images (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_3() {
  local id="4.3"
  local desc="Ensure that unnecessary packages are not installed in the container (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_4() {
  local id="4.4"
  local desc="Ensure images are scanned and rebuilt to include security patches (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_5() {
  local id="4.5"
  local desc="Ensure Content trust for Docker is Enabled (Scored)"
  local remediation="Add DOCKER_CONTENT_TRUST variable to the /etc/environment file using command echo DOCKER_CONTENT_TRUST=1 | sudo tee -a /etc/environment."
  local remediationImpact="This prevents users from working with tagged images unless they contain a signature."
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ "x$DOCKER_CONTENT_TRUST" = "x1" ]; then
    pass -s "$check"
    logcheckresult "PASS"
  else
    warn -s "$check"
    logcheckresult "WARN"
  fi
}

check_4_6() {
  local id="4.6"
  local desc="Ensure that HEALTHCHECK instructions have been added to container images (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  no_health_images=""
  for img in $images; do
    if docker inspect --format='{{.Config.Healthcheck}}' "$img" 2>/dev/null | grep -e "<nil>" >/dev/null 2>&1; then
      if [ $fail -eq 0 ]; then
        fail=1
        warn -s "$check"
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
    pass -s "$check"
    logcheckresult "PASS"
  else
    logcheckresult "WARN" "Images w/o HEALTHCHECK" "$no_health_images"
  fi
}

check_4_7() {
  local id="4.7"
  local desc="Ensure update instructions are not used alone in the Dockerfile (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  update_images=""
  for img in $images; do
    if docker history "$img" 2>/dev/null | grep -e "update" >/dev/null 2>&1; then
      if [ $fail -eq 0 ]; then
        fail=1
        info -c "$check"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        info "     * Update instruction found: $imgName"
        update_images="$update_images $imgName"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
    pass -c "$check"
    logcheckresult "PASS"
  else
    logcheckresult "INFO" "Update instructions found" "$update_images"
  fi
}

check_4_8() {
  local id="4.8"
  local desc="Ensure setuid and setgid permissions are removed (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_9() {
  local id="4.9"
  local desc="Ensure that COPY is used instead of ADD in Dockerfiles (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  fail=0
  add_images=""
  for img in $images; do
    if docker history --format "{{ .CreatedBy }}" --no-trunc "$img" | \
      sed '$d' | grep -q 'ADD'; then
      if [ $fail -eq 0 ]; then
        fail=1
        info -c "$check"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        info "     * ADD in image history: $imgName"
        add_images="$add_images $imgName"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
    pass -c "$check"
    logcheckresult "PASS"
  else
    logcheckresult "INFO" "Images using ADD" "$add_images"
  fi
}

check_4_10() {
  local id="4.10"
  local desc="Ensure secrets are not stored in Dockerfiles (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_11() {
  local id="4.11"
  local desc="Ensure only verified packages are are installed (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_end() {
  endsectionjson
}
