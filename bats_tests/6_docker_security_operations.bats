#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"
load "$BATS_TEST_DIRNAME/../helper_lib.sh"


# 6.4
@test "6.4 - Avoid image sprawl" {
  images=$(docker images -q | sort -u | wc -l | awk '{print $1}')
  active_images=0

  for c in $(docker inspect -f "{{.Image}}" $(docker ps -qa)); do
    if docker images --no-trunc -a | grep "$c" > /dev/null ; then
      active_images=$(( active_images += 1 ))
    fi
  done

  if [ "$images" -gt 100 ]; then
    fail "There are currently: $images images"
  fi

  if [ "$active_images" -lt "$((images / 2))" ]; then
    fail "Only $active_images out of $images are in use"
  fi
}

# 6.5
@test "6.5 - Avoid container sprawl" {
  total_containers=$(docker info 2>/dev/null | grep "Containers" | awk '{print $2}')
  running_containers=$(docker ps -q | wc -l | awk '{print $1}')
  diff="$((total_containers - running_containers))"
  if [ "$diff" -gt 25 ]; then
    fail "There are currently a total of $total_containers containers, with only $running_containers of them currently running"
  fi
}
