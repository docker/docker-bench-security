#!/bin/sh
# ------------------------------------------------------------------------------
# CIS Docker 1.6 Benchmark v1.0.0 checker
#
# Docker, Inc. (c) 2015
#
# Provides automated tests for the CIS Docker 1.6 Benchmark:
# https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_1.6_Benchmark_v1.0.0.pdf
#
# ------------------------------------------------------------------------------

# Load dependencies
. ./output_lib.sh
. ./helper_lib.sh

# Setup the paths
this_path=$(abspath $0)       ## Path of this file including filenamel
dir_name=`dirname ${this_path}`    ## Dir where this file is
myname=`basename ${this_path}`     ## file name of this script.
logger="${myname}.log"


# Check for required program(s)
req_progs='docker netstat grep awk'
for p in $req_progs; do
  command -v $p >/dev/null 2>&1 || { printf "$p command not found.\n"; exit 1; }
done

# Ensure we can connect to docker daemon
`docker ps -q >/dev/null 2>&1`
if [ $? -ne 0 ]; then
  printf "Error connecting to docker daemon (does docker ps work?)\n"
  exit 1
fi

usage () {
  printf "
  usage: $myname [options]

  -h           optional  Print this help message\n"
  exit 1
}

yell "# ------------------------------------------------------------------------------
# CIS Docker 1.6 Benchmark v1.0.0 checker
#
# Docker, Inc. (c) 2015
#
# Provides automated tests for the CIS Docker 1.6 Benchmark:
# https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_1.6_Benchmark_v1.0.0.pdf
# ------------------------------------------------------------------------------"

logit "Initializing `date`\n"

# Warn if not root
ID=`id -u`
if [ "x$ID" != "x0" ]; then
    warn "Some tests might require root to run"
    sleep 3
fi

# Get the flags
while getopts :hlfi: args
do
  case $args in
  h) usage ;;
  l) logger="$OPTARG" ;;
  *) usage ;;
  esac
done

# Load all the tests from tests/ and run them
main () {
  # List all running containers
  containers=`docker ps -q`
  # If there is a container with label docker-bench, memorize it:
  benchcont="nil"
  for c in $containers; do
    labels=`docker inspect --format '{{ .Config.Labels }}' $c`
    contains "$labels" "docker-bench" && benchcont="$c"
  done
  # List all running containers except docker-bench
  containers=`docker ps -q | grep -v $benchcont`

  for test in tests/*.sh
  do
     . ./$test
  done
}

main "$@"
