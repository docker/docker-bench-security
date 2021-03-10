#!/bin/sh

check_7() {
  logit ""
  local id="7"
  local desc="Docker Swarm Configuration"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

# 7.1
check_7_1() {
  local id="7.1"
  local desc="Ensure swarm mode is not Enabled, if not needed (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:*\sinactive\s*" >/dev/null 2>&1; then
    pass "$check"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 7.2
check_7_2() {
  local id="7.2"
  local desc="Ensure that the minimum number of manager nodes have been created in a swarm (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    managernodes=$(docker node ls | grep -c "Leader")
    if [ "$managernodes" -eq 1 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check (Swarm mode not enabled)"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.3
check_7_3() {
  local id="7.3"
  local desc="Ensure that swarm services are bound to a specific host interface (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
    $netbin -lnt | grep -e '\[::]:2377 ' -e ':::2377' -e '*:2377 ' -e ' 0\.0\.0\.0:2377 ' >/dev/null 2>&1
    if [ $? -eq 1 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    pass "$check (Swarm mode not enabled)"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.4
check_7_4() {
  local id="7.4"
  local desc="Ensure that all Docker swarm overlay networks are encrypted (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  fail=0
  unencrypted_networks=""
  for encnet in $(docker network ls --filter driver=overlay --quiet); do
    if docker network inspect --format '{{.Name}} {{ .Options }}' "$encnet" | \
      grep -v 'encrypted:' 2>/dev/null 1>&2; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        warn "$check"
        fail=1
      fi
      warn "     * Unencrypted overlay network: $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
      unencrypted_networks="$unencrypted_networks $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
    fi
  done
  # We went through all the networks and found none that are unencrypted
  if [ $fail -eq 0 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
  else
      resulttestjson "WARN" "Unencrypted overlay networks:" "$unencrypted_networks"
      currentScore=$((currentScore - 1))
  fi
}

# 7.5
check_7_5() {
  local id="7.5"
  local desc="Ensure that Docker's secret management commands are used for managing secrets in a swarm cluster (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if [ "$(docker secret ls -q | wc -l)" -ge 1 ]; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      info "$check"
      resulttestjson "INFO"
      currentScore=$((currentScore + 0))
    fi
  else
    pass "$check (Swarm mode not enabled)"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.6
check_7_6() {
  local id="7.6"
  local desc="Ensure that swarm manager is run in auto-lock mode (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if ! docker swarm unlock-key 2>/dev/null | grep 'SWMKEY' 2>/dev/null 1>&2; then
      warn "$check"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    else
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    fi
  else
    pass "$check (Swarm mode not enabled)"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.7
check_7_7() {
  local id="7.7"
  local desc="Ensure that the swarm manager auto-lock key is rotated periodically (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    note "$check"
    resulttestjson "NOTE"
    currentScore=$((currentScore + 0))
  else
    pass "$check (Swarm mode not enabled)"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.8
check_7_8() {
  local id="7.8"
  local desc="Ensure that node certificates are rotated as appropriate (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    if docker info 2>/dev/null | grep "Expiry Duration: 2 days"; then
      pass "$check"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      info "$check"
      resulttestjson "INFO"
      currentScore=$((currentScore + 0))
    fi
  else
    pass "$check (Swarm mode not enabled)"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.9
check_7_9() {
  local id="7.9"
  local desc="Ensure that CA certificates are rotated as appropriate (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    info "$check"
    resulttestjson "INFO"
    currentScore=$((currentScore + 0))
  else
    pass "$check (Swarm mode not enabled)"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 7.10
check_7_10() {
  local id="7.10"
  local desc="Ensure that management plane traffic is separated from data plane traffic (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
    info "$check"
    resulttestjson "INFO"
    currentScore=$((currentScore + 0))
  else
    pass "$check (Swarm mode not enabled)"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  fi
}

check_7_end() {
  endsectionjson
}
