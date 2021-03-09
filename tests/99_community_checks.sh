#!/bin/sh
check_c() {
  logit "\n"
  local id="99"
  local desc="Community contributed checks"
  local check="$id - $desc"
  info "$check"
  startsectionjson "$id" "$desc"
}

# check_c_1
check_c_1() {
  local check="C.1  - This is a example check"
  totalChecks=$((totalChecks + 1))
  if docker info --format='{{ .Architecture }}' | grep 'x86_64' 2>/dev/null 1>&2; then
    pass "$check"
    resulttestjson "PASS"
  else
    warn "$check"
    resulttestjson "WARN"
  fi
}

# check_c_2
check_c_2() {
  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,.' | cut -c 1-4)
  totalChecks=$((totalChecks + 1))

  local id="C.2"
  local desc="Ensure operations on legacy registry (v1) are Disabled"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  if [ "$docker_version" -lt 1712 ]; then
    if get_docker_configuration_file_args 'disable-legacy-registry' | grep 'true' >/dev/null 2>&1; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    elif get_docker_effective_command_line_args '--disable-legacy-registry' | grep "disable-legacy-registry" >/dev/null 2>&1; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    local desc="$desc (Deprecated)"
    local check="$id  - $desc"
    info "$check"
    resulttestjson "INFO"
  fi
}

check_c_end() {
  endsectionjson
}
