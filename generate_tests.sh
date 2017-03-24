#!/bin/bash

. ./helper_lib.sh

TEST_SRC=./bats_tests
BENCH_ROOT=/var/docker-bench
TEST_ROOT=$BENCH_ROOT/bats_tests

prepare_tests_directory()
{
  mkdir -p $BENCH_ROOT
  if [ -d "$TEST_ROOT" ]; then
    rm -rf $TEST_ROOT
  fi
  if [ ! -f "$BENCH_ROOT/helper_lib.sh" ]; then
    cp helper_lib.sh $BENCH_ROOT
  fi
  cp -r $TEST_SRC $TEST_ROOT
}

list_running_containers() {
    # List all running containers
  containers=($(docker ps | sed '1d' | awk '{print $NF}' | tr "\n" " "))
  # If there is a container with label docker_bench_security, memorize it:
  local benchcont="nil"
  for c in "${containers[@]}"; do
    labels=$(docker inspect --format '{{ .Config.Labels }}' "$c")
    contains "$labels" "docker_bench_security" && benchcont="$c"
  done
  # List all running containers except docker-bench (use names to improve readability in logs)
  docker ps -aq --format="{{.Names}}" | grep -v "$benchcont" | tr "\n" " "
}

generate_all_tests() {
  # prepare test direcory: copy tests and templates
  prepare_tests_directory
  # generate tests from templates for running containers
  containers=($(list_running_containers))
  ( cd $TEST_ROOT || exit 1
  for c in "${containers[@]}"; do
    for t in *.bats.template; do
      sed -e "s/{{c}}/$c/g" "${t}" > "${t%.*.*}_${c}.bats"
    done
  done
  )
}
