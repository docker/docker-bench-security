#!/bin/sh
check_c() {
  logit "\n"
  id_99="99"
  desc_99="Community contributed checks"
  check_99="$id_99 - $desc_99"
  info "$check_99"
  startsectionjson "$id_99" "$desc_99"
}

# check_c_1
check_c_1() {
  check_c_1="C.1  - This is a example check"
  totalChecks=$((totalChecks + 1))
  if docker info --format='{{ .Architecture }}' | grep 'x86_64' 2>/dev/null 1>&2; then
    pass "$check_c_1"
    resulttestjson "PASS"
  else
    warn "$check_c_1"
    resulttestjson "WARN"
  fi
}

# check_c_2
check_c_2() {
  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,.' | cut -c 1-4)
  totalChecks=$((totalChecks + 1))

  id_c_2="C.2"
  desc_c_2="Ensure operations on legacy registry (v1) are Disabled"
  check_c_2="$id_c_2  - $desc_c_2"
  starttestjson "$id_c_2" "$desc_c_2"

  if [ "$docker_version" -lt 1712 ]; then
    if get_docker_configuration_file_args 'disable-legacy-registry' | grep 'true' >/dev/null 2>&1; then
      pass "$check_c_2"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    elif get_docker_effective_command_line_args '--disable-legacy-registry' | grep "disable-legacy-registry" >/dev/null 2>&1; then
      pass "$check_c_2"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_c_2"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    desc_c_2="$desc_c_2 (Deprecated)"
    check_c_2="$id_c_2  - $desc_c_2"
    info "$check_c_2"
    resulttestjson "INFO"
  fi
}

check_c_end() {
  endsectionjson
}
