#!/bin/sh

logit "\n"
info "6 - Docker Security Operations"

# 6.1
check_6_1="6.1  - Perform regular security audits of your host system and containers"
info "$check_6_1"

# 6.2
check_6_2="6.2  - Monitor Docker containers usage, performance and metering"
info "$check_6_2"

# 6.3
check_6_3="6.3  - Backup container data"
info "$check_6_3"

# 6.4
check_6_4="6.4  - Avoid image sprawl"
images=$(docker images -q | sort -u | wc -l | awk '{print $1}')
active_images=0

for c in $(docker inspect -f "{{.Image}}" $(docker ps -qa)); do
  if docker images --no-trunc -a | grep "$c" > /dev/null ; then
    active_images=$(( active_images += 1 ))
  fi
done

  info "$check_6_4"
  info "     * There are currently: $images images"

if [ "$active_images" -lt "$((images / 2))" ]; then
  info "     * Only $active_images out of $images are in use"
fi

# 6.5
check_6_5="6.5  - Avoid container sprawl"
total_containers=$(docker info 2>/dev/null | grep "Containers" | awk '{print $2}')
running_containers=$(docker ps -q | wc -l | awk '{print $1}')
diff="$((total_containers - running_containers))"
if [ "$diff" -gt 25 ]; then
  info "$check_6_5"
  info "     * There are currently a total of $total_containers containers, with only $running_containers of them currently running"
else
  info "$check_6_5"
  info "     * There are currently a total of $total_containers containers, with $running_containers of them currently running"
fi
