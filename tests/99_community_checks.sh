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

check_c_end() {
  endsectionjson
}
