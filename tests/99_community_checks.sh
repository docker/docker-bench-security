#!/bin/sh
check_c() {
  logit "\n"
  info "99 - Community contributed checks"
}

# check_c_1
check_c_1() {
  check_c_1="C.1  - This is a example check"
  totalChecks=$((totalChecks + 1))
  if docker info --format='{{ .Architecture }}' | grep 'x86_64' 2>/dev/null 1>&2; then
    pass "$check_c_1"
    logjson "c.1" "PASS"
  else
    warn "$check_c_1"
    logjson "c.1" "WARN"
  fi
}
