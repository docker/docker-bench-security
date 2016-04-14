#!/bin/sh

logit "\n"
info "6  - Docker Security Operations"

# 6.4
check_6_4="6.4 - Avoid image sprawl"
images=$(docker images -q | sort -u | wc -l | awk '{print $1}')
active_images=0

for c in $(docker inspect -f "{{.Image}}" $(docker ps -qa)); do
  if docker images --no-trunc -a | grep "$c" > /dev/null ; then
    active_images=$(( active_images += 1 ))
  fi
done

if [ "$images" -gt 100 ]; then
  warn "$check_6_4"
  warn "     * There are currently: $images images"
else
  info "$check_6_4"
  info "     * There are currently: $images images"
fi

if [ "$active_images" -lt "$((images / 2))" ]; then
  warn "     * Only $active_images out of $images are in use"
fi

# 6.5
check_6_5="6.5 - Avoid container sprawl"
total_containers=$(docker info 2>/dev/null | grep "Containers" | awk '{print $2}')
running_containers=$(docker ps -q | wc -l | awk '{print $1}')
diff="$((total_containers - running_containers))"
if [ "$diff" -gt 25 ]; then
  warn "$check_6_5"
  warn "     * There are currently a total of $total_containers containers, with only $running_containers of them currently running"
else
  info "$check_6_5"
  info "     * There are currently a total of $total_containers containers, with $running_containers of them currently running"
fi
