#!/bin/sh

host_configuration() {
  check_1
  check_1_1
  check_1_2
  check_1_5
  check_1_6
  check_1_7
  check_1_8
  check_1_9
  check_1_10
  check_1_11
  check_1_12
  check_1_13
  check_1_14
  check_1_15
  check_1_16
  check_1_17
  check_1_18
}

docker_daemon_configuration() {
  check_2
  check_2_1
  check_2_2
  check_2_3
  check_2_4
  check_2_5
  check_2_6
  check_2_7
  check_2_8
  check_2_9
  check_2_10
}

docker_daemon_files() {
  check_3
  check_3_1
  check_3_2
  check_3_3
  check_3_4
  check_3_5
  check_3_6
  check_3_7
  check_3_8
  check_3_9
  check_3_10
  check_3_11
  check_3_12
  check_3_13
  check_3_14
  check_3_15
  check_3_16
  check_3_17
  check_3_18
  check_3_19
  check_3_20
  check_3_21
  check_3_22
  check_3_23
  check_3_24
  check_3_25
  check_3_26
}

container_images() {
  check_4
  check_4_1
}

container_runtime() {
  check_5
  check_running_containers
  check_5_1
  check_5_2
  check_5_3
  check_5_4
  check_5_5
  check_5_6
  check_5_8
  check_5_8
  check_5_10
  check_5_11
  check_5_12
  check_5_12
  check_5_14
  check_5_15
  check_5_16
  check_5_17
  check_5_18
  check_5_19
}

docker_security_operations() {
  check_6
  check_6_5
  check_6_6
  check_6_7
}

# CIS
cis() {
  host_configuration
  docker_daemon_configuration
  docker_daemon_files
  container_images
  container_runtime
  docker_security_operations
}

# Community contributed
community() {
  check_community
  check_community_1
}

# All
all() {
  cis
  community
}
