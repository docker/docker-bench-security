#!/bin/sh

check_6() {
  logit "\n"
  id_6="6"
  desc_6="Docker Security Operations"
  check_6="$id_6 - $desc_6"
  info "$check_6"
  startsectionjson "$id_6" "$desc_6"
}

# 6.1
check_6_1() {
  id_6_1="6.1"
  desc_6_1="Ensure that image sprawl is avoided (Not Scored)"
  check_6_1="$id_6_1  - $desc_6_1"
  starttestjson "$id_6_1" "$desc_6_1"

  totalChecks=$((totalChecks + 1))
  images=$(docker images -q | sort -u | wc -l | awk '{print $1}')
  active_images=0

  for c in $(docker inspect --format "{{.Image}}" $(docker ps -qa) 2>/dev/null); do
    if docker images --no-trunc -a | grep "$c" > /dev/null ; then
      active_images=$(( active_images += 1 ))
    fi
  done

    info "$check_6_1"
    info "     * There are currently: $images images"

  if [ "$active_images" -lt "$((images / 2))" ]; then
    info "     * Only $active_images out of $images are in use"
  fi
  resulttestjson "INFO" "$active_images active/$images in use"
  currentScore=$((currentScore + 0))
}

# 6.2
check_6_2() {
  id_6_2="6.2"
  desc_6_2="Ensure that container sprawl is avoided (Not Scored)"
  check_6_2="$id_6_2  - $desc_6_2"
  starttestjson "$id_6_2" "$desc_6_2"

  totalChecks=$((totalChecks + 1))
  total_containers=$(docker info 2>/dev/null | grep "Containers" | awk '{print $2}')
  running_containers=$(docker ps -q | wc -l | awk '{print $1}')
  diff="$((total_containers - running_containers))"
  if [ "$diff" -gt 25 ]; then
    info "$check_6_2"
    info "     * There are currently a total of $total_containers containers, with only $running_containers of them currently running"
    resulttestjson "INFO" "$total_containers total/$running_containers running"
  else
    info "$check_6_2"
    info "     * There are currently a total of $total_containers containers, with $running_containers of them currently running"
    resulttestjson "INFO" "$total_containers total/$running_containers running"
  fi
  currentScore=$((currentScore + 0))
}

check_6_end() {
  endsectionjson
}
