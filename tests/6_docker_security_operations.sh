#!/bin/sh

check_6() {
  logit ""
  local id="6"
  local desc="Docker Security Operations"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_6_1() {
  local id="6.1"
  local desc="Ensure that image sprawl is avoided (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  images=$(docker images -q | sort -u | wc -l | awk '{print $1}')
  active_images=0

  for c in $(docker inspect --format "{{.Image}}" $(docker ps -qa) 2>/dev/null); do
    if docker images --no-trunc -a | grep "$c" > /dev/null ; then
      active_images=$(( active_images += 1 ))
    fi
  done

  info -c "$check"
  info "     * There are currently: $images images"

  if [ "$active_images" -lt "$((images / 2))" ]; then
    info "     * Only $active_images out of $images are in use"
  fi
  logcheckresult "INFO" "$active_images active/$images in use"
}

check_6_2() {
  local id="6.2"
  local desc="Ensure that container sprawl is avoided (Not Scored)"
  local check="$id  - $desc"
  starttestjson "$id" "$desc"

  total_containers=$(docker info 2>/dev/null | grep "Containers" | awk '{print $2}')
  running_containers=$(docker ps -q | wc -l | awk '{print $1}')
  diff="$((total_containers - running_containers))"
  info -c "$check"
  if [ "$diff" -gt 25 ]; then
    info "     * There are currently a total of $total_containers containers, with only $running_containers of them currently running"
  else
    info "     * There are currently a total of $total_containers containers, with $running_containers of them currently running"
  fi
  logcheckresult "INFO" "$total_containers total/$running_containers running"
}

check_6_end() {
  endsectionjson
}
