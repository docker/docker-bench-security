#!/bin/sh

check_8() {
  logit ""
  local id="8"
  local desc="Docker Enterprise Configuration"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_product_license() {
  if docker version | grep -Eqi '^Server.*Community$|Version.*-ce$'; then
    info "  * Community Engine license, skipping section 8"
    enterprise_license=0
  else
    enterprise_license=1
  fi
}

check_8_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1"
  local desc="Universal Control Plane Configuration"
  local check="$id - $desc"
  info "$check"
}

# 8.1.1
check_8_1_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.1"
  local desc="Configure the LDAP authentication service (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  note "$check"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.2
check_8_1_2() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.2"
  local desc="Use external certificates (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  note "$check"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.3
check_8_1_3() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.3"
  local desc="Enforce the use of client certificate bundles for unprivileged users (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  note "$check"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.4
check_8_1_4() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.4"
  local desc="Configure applicable cluster role-based access control policies (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  note "$check"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.5
check_8_1_5() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.5"
  local desc="Enable signed image enforcement (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  note "$check"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.6
check_8_1_6() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.6"
  local desc="Set the Per-User Session Limit to a value of '3' or lower (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  note "$check"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.7
check_8_1_7() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.7"
  local desc="Set the 'Lifetime Minutes' and 'Renewal Threshold Minutes' values to '15' or lower and '0' respectively (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  note "$check"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

check_8_2() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.2"
  local desc="Docker Trusted Registry Configuration"
  local check="$id - $desc"
  info "$check"
}

check_8_2_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.2.1"
  local desc="Enable image vulnerability scanning (Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  note "$check"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

check_8_end() {
  endsectionjson
}
