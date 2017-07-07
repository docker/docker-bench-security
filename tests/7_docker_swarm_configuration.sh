#!/bin/sh

logit "\n"
info "7 - Docker Swarm Configuration"

# 7.1
check_7_1="7.1  - Ensure swarm mode is not Enabled, if not needed"
if docker info 2>/dev/null | grep -e "Swarm:*\sinactive\s*" >/dev/null 2>&1; then
  pass "$check_7_1"
else
  warn "$check_7_1"
fi

# 7.2
check_7_2="7.2  - Ensure the minimum number of manager nodes have been created in a swarm"
if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
  managernodes=$(docker node ls | grep -c "Leader")
  if [ "$managernodes" -le 1 ]; then
    pass "$check_7_2"
  else
    warn "$check_7_2"
  fi
else
  pass "$check_7_2 (Swarm mode not enabled)"
fi

# 7.3
check_7_3="7.3  - Ensure swarm services are binded to a specific host interface"
if docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*" >/dev/null 2>&1; then
  netstat -lnt | grep -e '\[::]:2377 ' -e ':::2377' -e '*:2377 ' -e ' 0\.0\.0\.0:2377 ' >/dev/null 2>&1
  if [ $? -eq 1 ]; then
    pass "$check_7_3"
  else
    warn "$check_7_3"
  fi
else
  pass "$check_7_3 (Swarm mode not enabled)"
fi

# 7.4
check_7_4="7.4  - Ensure data exchanged between containers are encrypted on different nodes on the overlay network"
if docker network ls --filter driver=overlay --quiet | \
  xargs docker network inspect --format '{{.Name}} {{ .Options }}' 2>/dev/null | \
    grep -v 'encrypted:' 2>/dev/null 1>&2; then
  warn "$check_7_4"
  for encnet in $(docker network ls --filter driver=overlay --quiet); do
    if docker network inspect --format '{{.Name}} {{ .Options }}' "$encnet" | \
       grep -v 'encrypted:' 2>/dev/null 1>&2; then
      warn "     * Unencrypted overlay network: $(docker network inspect --format '{{ .Name }} ({{ .Scope }})' "$encnet")"
    fi
  done
else
  pass "$check_7_4"
fi

# 7.5
check_7_5="7.5  - Ensure Docker's secret management commands are used for managing secrets in a Swarm cluster"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
  if [ "$(docker secret ls -q | wc -l)" -ge 1 ]; then
    pass "$check_7_5"
  else
    info "$check_7_5"
  fi
else
  pass "$check_7_5 (Swarm mode not enabled)"
fi

# 7.6
check_7_6="7.6  - Ensure swarm manager is run in auto-lock mode"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
  if ! docker swarm unlock-key 2>/dev/null | grep 'SWMKEY' 2>/dev/null 1>&2; then
    warn "$check_7_6"
  else
    pass "$check_7_6"
  fi
else
  pass "$check_7_6 (Swarm mode not enabled)"
fi

# 7.7
check_7_7="7.7  - Ensure swarm manager auto-lock key is rotated periodically"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
  note "$check_7_7"
else
  pass "$check_7_7 (Swarm mode not enabled)"
fi

# 7.8
check_7_8="7.8  - Ensure node certificates are rotated as appropriate"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
  if docker info 2>/dev/null | grep "Expiry Duration: 2 days"; then
    pass "$check_7_8"
  else
    info "$check_7_8"
  fi
else
  pass "$check_7_8 (Swarm mode not enabled)"
fi

# 7.9
check_7_9="7.9  - Ensure CA certificates are rotated as appropriate"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
	info "$check_7_9"
else
	pass "$check_7_9 (Swarm mode not enabled)"
fi

# 7.10
check_7_10="7.10 - Ensure management plane traffic has been separated from data plane traffic"
if docker info 2>/dev/null | grep -e "Swarm:\s*active\s*" >/dev/null 2>&1; then
	info "$check_7_10"
else
	pass "$check_7_10 (Swarm mode not enabled)"
fi
