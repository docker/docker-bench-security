#!/bin/sh

check_8() {
  logit "\n"
  id_8="8"
  desc_8="Docker Enterprise Configuration"
  check_8="$id_8 - $desc_8"
  info "$check_8"
  startsectionjson "$id_8" "$desc_8"
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

  id_8_1="8.1"
  desc_8_1="Universal Control Plane Configuration"
  check_8_1="$id_8_1 - $desc_8_1"
  info "$check_8_1"
}

# 8.1.1
check_8_1_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_1="8.1.1"
  desc_8_1_1="Configure the LDAP authentication service (Scored)"
  check_8_1_1="$id_8_1_1  - $desc_8_1_1"
  starttestjson "$id_8_1_1" "$desc_8_1_1"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_1"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.2
check_8_1_2() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_2="8.1.2"
  desc_8_1_2="Use external certificates (Scored)"
  check_8_1_2="$id_8_1_2  - $desc_8_1_2"
  starttestjson "$id_8_1_2" "$desc_8_1_2"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_2"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.3
check_8_1_3() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_3="8.1.3"
  desc_8_1_3="Enforce the use of client certificate bundles for unprivileged users (Not Scored)"
  check_8_1_3="$id_8_1_3  - $desc_8_1_3"
  starttestjson "$id_8_1_3" "$desc_8_1_3"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_3"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.4
check_8_1_4() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_4="8.1.4"
  desc_8_1_4="Configure applicable cluster role-based access control policies (Not Scored)"
  check_8_1_4="$id_8_1_4  - $desc_8_1_4"
  starttestjson "$id_8_1_4" "$desc_8_1_4"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_4"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.5
check_8_1_5() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_5="8.1.5"
  desc_8_1_5="Enable signed image enforcement (Scored)"
  check_8_1_5="$id_8_1_5  - $desc_8_1_5"
  starttestjson "$id_8_1_5" "$desc_8_1_5"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_5"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.6
check_8_1_6() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_6="8.1.6"
  desc_8_1_6="Set the Per-User Session Limit to a value of '3' or lower (Scored)"
  check_8_1_6="$id_8_1_6  - $desc_8_1_6"
  starttestjson "$id_8_1_6" "$desc_8_1_6"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_6"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 8.1.7
check_8_1_7() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_1_7="8.1.7"
  desc_8_1_7="Set the 'Lifetime Minutes' and 'Renewal Threshold Minutes' values to '15' or lower and '0' respectively (Scored)"
  check_8_1_7="$id_8_1_7  - $desc_8_1_7"
  starttestjson "$id_8_1_7" "$desc_8_1_7"

  totalChecks=$((totalChecks + 1))
  note "$check_8_1_7"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

check_8_2() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  logit "\n"
  id_8_2="8.2"
  desc_8_2="Docker Trusted Registry Configuration"
  check_8_2="$id_8_2 - $desc_8_2"
  info "$check_8_2"
}

check_8_2_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  id_8_2_1="8.2.1"
  desc_8_2_1="Enable image vulnerability scanning (Scored)"
  check_8_2_1="$id_8_2_1  - $desc_8_2_1"
  starttestjson "$id_8_2_1" "$desc_8_2_1"

  totalChecks=$((totalChecks + 1))
  note "$check_8_2_1"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

check_8_end() {
  endsectionjson
}
