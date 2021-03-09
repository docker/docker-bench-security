#!/bin/sh

check_6() {
  logit "\n"
  local id="6"
  local desc="Docker Security Operations"
  local check="$id - $desc"
  info "$check"
  startsectionjson "$id" "$desc"
}

# 6.1
check_6_1() {
  local id="6.1"
  local desc="Ensure that image sprawl is avoided (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  images=$(docker images -q | sort -u | wc -l | awk '{print $1}')
  active_images=0

  for c in $(docker inspect --format "{{.Image}}" $(docker ps -qa) 2>/dev/null); do
    if docker images --no-trunc -a | grep "$c" > /dev/null ; then
      active_images=$(( active_images += 1 ))
    fi
  done

    info "$check"
    info "     * There are currently: $images images"

  if [ "$active_images" -lt "$((images / 2))" ]; then
    info "     * Only $active_images out of $images are in use"
  fi
  resulttestjson "INFO" "$active_images active/$images in use"
  currentScore=$((currentScore + 0))
}

# 6.2
check_6_2() {
  local id="6.2"
  local desc="Ensure that container sprawl is avoided (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  totalChecks=$((totalChecks + 1))
  total_containers=$(docker info 2>/dev/null | grep "Containers" | awk '{print $2}')
  running_containers=$(docker ps -q | wc -l | awk '{print $1}')
  diff="$((total_containers - running_containers))"
  if [ "$diff" -gt 25 ]; then
    info "$check"
    info "     * There are currently a total of $total_containers containers, with only $running_containers of them currently running"
    resulttestjson "INFO" "$total_containers total/$running_containers running"
  else
    info "$check"
    info "     * There are currently a total of $total_containers containers, with $running_containers of them currently running"
    resulttestjson "INFO" "$total_containers total/$running_containers running"
  fi
  currentScore=$((currentScore + 0))
}

check_6_end() {
  endsectionjson
}
