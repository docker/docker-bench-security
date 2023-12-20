#!/bin/bash

check_7() {
  logit ""
  local id="7"
  local desc="Docker Swarm Configuration"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_7_1() {
  local id="7.1"
  local desc="Ensure that the minimum number of manager nodes have been created in a swarm (Automated)"
  local remediation="If an excessive number of managers is configured, the excess nodes can be demoted to workers using command: docker node demote <manager node ID to be demoted>"
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    managernodes=$(docker node ls | grep -c "Leader")
    if [ "$managernodes" -eq 1 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check (Swarm mode not enabled)"
  logcheckresult "PASS"
}

check_7_2() {
  local id="7.2"
  local desc="Ensure that swarm services are bound to a specific host interface (Automated)"
  local remediation="Resolving this issues requires re-initialization of the swarm, specifying a specific interface for the --listen-addr parameter."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    $netbin -lnt | grep -e '\[::]:2377 ' -e ':::2377' -e '*:2377 ' -e ' 0\.0\.0\.0:2377 ' >/dev/null 2>&1
    if [ $? -eq 1 ]; then
      pass -s "$check"
      logcheckresult "PASS"
      return
    fi
    warn -s "$check"
    logcheckresult "WARN"
    return
  fi
  pass -s "$check (Swarm mode not enabled)"
  logcheckresult "PASS"
}

check_7_3() {
  local id="7.3"
  local desc="Ensure that all Docker swarm overlay networks are encrypted (Automated)"
  local remediation="You should create overlay networks the with --opt encrypted flag."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  fail=0
  unencrypted_networks=""
  for encnet in $(docker network ls --filter driver=overlay --quiet); do
    if docker network inspect --format '{{.Name}} {{ .Options }}' "$encnet" | \
      grep -v 'encrypted:' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn -s "$check"
        fail=1
      fi
      warn "     * Unencrypted overlay network: $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
      unencrypted_networks="$unencrypted_networks $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
    fi
  done
  # We went through all the networks and found none that are unencrypted
  if [ $fail -eq 0 ]; then
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  logcheckresult "WARN" "Unencrypted overlay networks:" "$unencrypted_networks"
}

check_7_4() {
  local id="7.4"
  local desc="Ensure that Docker's secret management commands are used for managing secrets in a swarm cluster (Manual)"
  local remediation="You should follow the docker secret documentation and use it to manage secrets effectively."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if [ "$(docker secret ls -q | wc -l)" -ge 1 ]; then
      pass -c "$check"
      logcheckresult "PASS"
      return
    fi
    info -c "$check"
    logcheckresult "INFO"
    return
  fi
  pass -c "$check (Swarm mode not enabled)"
  logcheckresult "PASS"
}

check_7_5() {
  local id="7.5"
  local desc="Ensure that swarm manager is run in auto-lock mode (Automated)"
  local remediation="If you are initializing a swarm, use the command: docker swarm init --autolock. If you want to set --autolock on an existing swarm manager node, use the command: docker swarm update --autolock."
  local remediationImpact="A swarm in auto-lock mode will not recover from a restart without manual intervention from an administrator to enter the unlock key. This may not always be desirable, and should be reviewed at a policy level."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if ! docker swarm unlock-key 2>/dev/null | grep 'SWMKEY' 2>/dev/null 1>&2; then
      warn -s "$check"
      logcheckresult "WARN"
      return
    fi
    pass -s "$check"
    logcheckresult "PASS"
    return
  fi
  pass -s "$check (Swarm mode not enabled)"
  logcheckresult "PASS"
}

check_7_6() {
  local id="7.6"
  local desc="Ensure that the swarm manager auto-lock key is rotated periodically (Manual)"
  local remediation="You should run the command docker swarm unlock-key --rotate to rotate the keys. To facilitate auditing of this recommendation, you should maintain key rotation records and ensure that you establish a pre-defined frequency for key rotation."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    note -c "$check"
    logcheckresult "NOTE"
    return
  fi
  pass -c "$check (Swarm mode not enabled)"
  logcheckresult "PASS"
}

check_7_7() {
  local id="7.7"
  local desc="Ensure that node certificates are rotated as appropriate (Manual)"
  local remediation="You should run the command docker swarm update --cert-expiry 48h to set the desired expiry time on the node certificate."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if docker info 2>/dev/null | grep "Expiry Duration: 2 days"; then
      pass -c "$check"
      logcheckresult "PASS"
      return
    fi
    info -c "$check"
    logcheckresult "INFO"
    return
  fi
  pass -c "$check (Swarm mode not enabled)"
  logcheckresult "PASS"
}

check_7_8() {
  local id="7.8"
  local desc="Ensure that CA certificates are rotated as appropriate (Manual)"
  local remediation="You should run the command docker swarm ca --rotate to rotate a certificate."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    info -c "$check"
    logcheckresult "INFO"
    return
  fi
  pass -c "$check (Swarm mode not enabled)"
  logcheckresult "PASS"
}

check_7_9() {
  local id="7.9"
  local desc="Ensure that management plane traffic is separated from data plane traffic (Manual)"
  local remediation="You should initialize the swarm with dedicated interfaces for management and data planes respectively. Example: docker swarm init --advertise-addr=192.168.0.1 --data-path-addr=17.1.0.3"
  local remediationImpact="This requires two network interfaces per node."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    info -c "$check"
    logcheckresult "INFO"
    return
  fi
  pass -c "$check (Swarm mode not enabled)"
  logcheckresult "PASS"
}

check_7_end() {
  endsectionjson
}
