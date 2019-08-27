#!/bin/sh

check_8() {
  logit "\n"
  id_8="8"
  desc_8="Docker Enterprise Configuration"
  check_8="$id_8 - $desc_8"
  info "$check_8"
  startsectionjson "$id_8" "$desc_8"
}

check_8_1() {
  logit "\n"
  id_8_1="8.1"
  desc_8_1="Universal Control Plane Configuration"
  check_8_1="$id_8_1 - $desc_8_1"
  info "$check_8_1"
  startsectionjson "$id_8_1" "$desc_8_1"
}

check_8_1_end() {
  endsectionjson
}

check_8_2() {
  logit "\n"
  id_8_2="8.2"
  desc_8_2="Docker Trusted Registry Configuration"
  check_8_2="$id_8_2 - $desc_8_2"
  info "$check_8_2"
  startsectionjson "$id_8_2" "$desc_8_2"
}

check_8_2_end() {
  endsectionjson
}

check_8_end() {
  endsectionjson
}
