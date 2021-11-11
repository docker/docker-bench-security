#!/bin/bash

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
  local desc="Ensure that a user for the container has been created (Automated)"
  local remediation="You should ensure that the Dockerfile for each container image contains the information: USER <username or ID>. If there is no specific user created in the container base image, then make use of the useradd command to add a specific user before the USER instruction in the Dockerfile."
  local remediationImpact="Running as a non-root user can present challenges where you wish to bind mount volumes from the underlying host. In this case, care should be taken to ensure that the user running the contained process can read and write to the bound directory, according to their requirements."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  # If container_users is empty, there are no running containers
  if [ -z "$containers" ]; then
    info -c "$check"
    info "     * No containers running"
    logcheckresult "INFO" "No containers running"
    return
  fi
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
        continue
      fi
      warn "     * Running as root: $c"
      root_containers="$root_containers $c"
    fi
  done
  # We went through all the containers and found none running as root
  if [ $fail -eq 0 ]; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  logcheckresult "WARN" "running as root" "$root_containers"
  # Make the loop separator go back to space
  set +f; unset IFS
}

check_4_2() {
  local id="4.2"
  local desc="Ensure that containers use only trusted base images (Manual)"
  local remediation="Configure and use Docker Content trust. View the history of each Docker image to evaluate its risk, dependent on the sensitivity of the application you wish to deploy using it. Scan Docker images for vulnerabilities at regular intervals."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_3() {
  local id="4.3"
  local desc="Ensure that unnecessary packages are not installed in the container (Manual)"
  local remediation="You should not install anything within the container that is not required. You should consider using a minimal base image if you can. Some of the options available include BusyBox and Alpine. Not only can this trim your image size considerably, but there would also be fewer pieces of software which could contain vectors for attack."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_4() {
  local id="4.4"
  local desc="Ensure images are scanned and rebuilt to include security patches (Manual)"
  local remediation="Images should be re-built ensuring that the latest version of the base images are used, to keep the operating system patch level at an appropriate level. Once the images have been re-built, containers should be re-started making use of the updated images."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_5() {
  local id="4.5"
  local desc="Ensure Content trust for Docker is Enabled (Automated)"
  local remediation="Add DOCKER_CONTENT_TRUST variable to the /etc/environment file using command echo DOCKER_CONTENT_TRUST=1 | sudo tee -a /etc/environment."
  local remediationImpact="This prevents users from working with tagged images unless they contain a signature."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if [ "$DOCKER_CONTENT_TRUST" = "1" ]; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_4_6() {
  local id="4.6"
  local desc="Ensure that HEALTHCHECK instructions have been added to container images (Automated)"
  local remediation="You should follow the Docker documentation and rebuild your container images to include the HEALTHCHECK instruction."
  local remediationImpact="None."
  local check="$id - $desc"
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
    return
  fi
  logcheckresult "WARN" "Images w/o HEALTHCHECK" "$no_health_images"
}

check_4_7() {
  local id="4.7"
  local desc="Ensure update instructions are not used alone in the Dockerfile (Manual)"
  local remediation="You should use update instructions together with install instructions and version pinning for packages while installing them. This prevent caching and force the extraction of the required versions. Alternatively, you could use the --no-cache flag during the docker build process to avoid using cached layers."
  local remediationImpact="None."
  local check="$id - $desc"
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
    return
  fi
  logcheckresult "INFO" "Update instructions found" "$update_images"
}

check_4_8() {
  local id="4.8"
  local desc="Ensure setuid and setgid permissions are removed (Manual)"
  local remediation="You should allow setuid and setgid permissions only on executables which require them. You could remove these permissions at build time by adding the following command in your Dockerfile, preferably towards the end of the Dockerfile: RUN find / -perm /6000 -type f -exec chmod a-s {} ; || true"
  local remediationImpact="The above command would break all executables that depend on setuid or setgid permissions including legitimate ones. You should therefore be careful to modify the command to suit your requirements so that it does not reduce the permissions of legitimate programs excessively. Because of this, you should exercise a degree of caution and examine all processes carefully before making this type of modification in order to avoid outages."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_9() {
  local id="4.9"
  local desc="Ensure that COPY is used instead of ADD in Dockerfiles (Manual)"
  local remediation="You should use COPY rather than ADD instructions in Dockerfiles."
  local remediationImpact="Care needs to be taken in implementing this control if the application requires functionality that is part of the ADD instruction, for example, if you need to retrieve files from remote URLS."
  local check="$id - $desc"
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
    return
  fi
  logcheckresult "INFO" "Images using ADD" "$add_images"
}

check_4_10() {
  local id="4.10"
  local desc="Ensure secrets are not stored in Dockerfiles (Manual)"
  local remediation="Do not store any kind of secrets within Dockerfiles. Where secrets are required during the build process, make use of a secrets management tool, such as the buildkit builder included with Docker."
  local remediationImpact="A proper secrets management process will be required for Docker image building."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_11() {
  local id="4.11"
  local desc="Ensure only verified packages are installed (Manual)"
  local remediation="You should use a secure package distribution mechanism of your choice to ensure the authenticity of software packages."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "NOTE"
}

check_4_end() {
  endsectionjson
}
