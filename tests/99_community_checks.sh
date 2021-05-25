#!/bin/bash

check_c() {
  logit ""
  local id="99"
  local desc="Community contributed checks"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_c_1() {
  local id="C.1"
  local desc="This is a example check for a Automated check"
  local remediation="This is an example remediation measure for a Automated check"
  local remediationImpact="This is an example remediation impact for a Automated check"
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info --format='{{ .Architecture }}' | grep 'x86_64' 2>/dev/null 1>&2; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  if docker info --format='{{ .Architecture }}' | grep 'aarch64' 2>/dev/null 1>&2; then
    info -c "$check"
    logcheckresult "INFO"
    return
  fi
  warn -s "$check"
  logcheckresult "WARN"
}

check_c_1_1() {
  local id="C.1.1"
  local desc="This is a example check for a Manual check"
  local remediation="This is an example remediation measure for a Manual check"
  local remediationImpact="This is an example remediation impact for a Manual check"
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info --format='{{ .Architecture }}' | grep 'x86_64' 2>/dev/null 1>&2; then
    pass -c "$check"
    logcheckresult "PASS"
    return
  fi
  if docker info --format='{{ .Architecture }}' | grep 'aarch64' 2>/dev/null 1>&2; then
    info -c "$check"
    logcheckresult "INFO"
    return
  fi
  warn -c "$check"
  logcheckresult "WARN"
}

check_c_2() {
  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,.' | cut -c 1-4)

  local id="C.2"
  local desc="Ensure operations on legacy registry (v1) are Disabled"
  local remediation="Start docker daemon with --disable-legacy-registry=false flag. Starting with Docker 17.12, support for V1 registries has been removed, and the --disable-legacy-registry flag can no longer be used."
  local remediationImpact="Prevents the docker daemon from pull, push, and login operations against v1 registries."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if [ "$docker_version" -lt 1712 ]; then
    if get_docker_configuration_file_args 'disable-legacy-registry' | grep 'true' >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    if get_docker_effective_command_line_args '--disable-legacy-registry' | grep "disable-legacy-registry" >/dev/null 2>&1; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  local desc="$desc (Deprecated)"
  local check="$id - $desc"
  info -c "$check"
  logcheckresult "INFO"
}

check_c_end() {
  endsectionjson
}
