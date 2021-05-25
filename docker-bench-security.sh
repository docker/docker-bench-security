#!/bin/bash
# --------------------------------------------------------------------------------------------
# Docker Bench for Security
#
# Docker, Inc. (c) 2015-2021
#
# Checks for dozens of common best-practices around deploying Docker containers in production.
# --------------------------------------------------------------------------------------------

version='1.3.6'

# Load dependencies
. ./functions/functions_lib.sh
. ./functions/helper_lib.sh

# Setup the paths
this_path=$(abspath "$0")       ## Path of this file including filename
myname=$(basename "${this_path%.*}")     ## file name of this script.

readonly version
readonly this_path
readonly myname

export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin/"

# Check for required program(s)
req_programs 'awk docker grep stat tee tail wc xargs truncate sed'

# Ensure we can connect to docker daemon
if ! docker ps -q >/dev/null 2>&1; then
  printf "Error connecting to docker daemon (does docker ps work?)\n"
  exit 1
fi

usage () {
  cat <<EOF
Docker Bench for Security - Docker, Inc. (c) 2015-$(date +"%Y")
Checks for dozens of common best-practices around deploying Docker containers in production.
Based on the CIS Docker Benchmark 1.3.1.

Usage: ${myname}.sh [OPTIONS]

Example:
  - Only run check "2.2 - Ensure the logging level is set to 'info'":
      sh docker-bench-security.sh -c check_2_2
  - Run all available checks except the host_configuration group and "2.8 - Enable user namespace support":
      sh docker-bench-security.sh -e host_configuration,check_2_8
  - Run just the container_images checks except "4.5 - Ensure Content trust for Docker is Enabled":
      sh docker-bench-security.sh -c container_images -e check_4_5

Options:
  -b           optional  Do not print colors
  -h           optional  Print this help message
  -l FILE      optional  Log output in FILE, inside container if run using docker
  -u USERS     optional  Comma delimited list of trusted docker user(s)
  -c CHECK     optional  Comma delimited list of specific check(s) id
  -e CHECK     optional  Comma delimited list of specific check(s) id to exclude
  -i INCLUDE   optional  Comma delimited list of patterns within a container or image name to check
  -x EXCLUDE   optional  Comma delimited list of patterns within a container or image name to exclude from check
  -n LIMIT     optional  In JSON output, when reporting lists of items (containers, images, etc.), limit the number of reported items to LIMIT. Default 0 (no limit).
  -p PRINT     optional  Print remediation measures. Default: Don't print remediation measures.

Complete list of checks: <https://github.com/docker/docker-bench-security/blob/master/tests/>
Full documentation: <https://github.com/docker/docker-bench-security>
Released under the Apache-2.0 License.
EOF
}

# Default values
if [ ! -d log ]; then
  mkdir log
fi

logger="log/${myname}.log"
limit=0
printremediation="0"
globalRemediation=""

# Get the flags
# If you add an option here, please
# remember to update usage() above.
while getopts bhl:u:c:e:i:x:t:n:p args
do
  case $args in
  b) nocolor="nocolor";;
  h) usage; exit 0 ;;
  l) logger="$OPTARG" ;;
  u) dockertrustusers="$OPTARG" ;;
  c) check="$OPTARG" ;;
  e) checkexclude="$OPTARG" ;;
  i) include="$OPTARG" ;;
  x) exclude="$OPTARG" ;;
  n) limit="$OPTARG" ;;
  p) printremediation="1" ;;
  *) usage; exit 1 ;;
  esac
done

# Load output formating
. ./functions/output_lib.sh

yell_info

# Warn if not root
if [ "$(id -u)" != "0" ]; then
  warn "$(yell 'Some tests might require root to run')\n"
  sleep 3
fi

# Total Score
# Warn Scored -1, Pass Scored +1, Not Score -0

totalChecks=0
currentScore=0

logit "Initializing $(date +%Y-%m-%dT%H:%M:%S%:z)\n"
beginjson "$version" "$(date +%s)"

# Load all the tests from tests/ and run them
main () {
  logit "\n${bldylw}Section A - Check results${txtrst}"

  # Get configuration location
  get_docker_configuration_file

  # If there is a container with label docker_bench_security, memorize it:
  benchcont="nil"
  for c in $(docker ps | sed '1d' | awk '{print $NF}'); do
    if docker inspect --format '{{ .Config.Labels }}' "$c" | \
     grep -e 'docker.bench.security' >/dev/null 2>&1; then
      benchcont="$c"
    fi
  done

  # Get the image id of the docker_bench_security_image, memorize it:
  benchimagecont="nil"
  for c in $(docker images | sed '1d' | awk '{print $3}'); do
    if docker inspect --format '{{ .Config.Labels }}' "$c" | \
     grep -e 'docker.bench.security' >/dev/null 2>&1; then
      benchimagecont="$c"
    fi
  done

  if [ -n "$include" ]; then
    pattern=$(echo "$include" | sed 's/,/|/g')
    containers=$(docker ps | sed '1d' | awk '{print $NF}' | grep -v "$benchcont" | grep -E "$pattern")
    images=$(docker images | sed '1d' | grep -E "$pattern" | awk '{print $3}' | grep -v "$benchimagecont")
  elif [ -n "$exclude" ]; then
    pattern=$(echo "$exclude" | sed 's/,/|/g')
    containers=$(docker ps | sed '1d' | awk '{print $NF}' | grep -v "$benchcont" | grep -Ev "$pattern")
    images=$(docker images | sed '1d' | grep -Ev "$pattern" | awk '{print $3}' | grep -v "$benchimagecont")
  else
    containers=$(docker ps | sed '1d' | awk '{print $NF}' | grep -v "$benchcont")
    images=$(docker images -q | grep -v "$benchcont")
  fi

  for test in tests/*.sh; do
    . ./"$test"
  done

  if [ -z "$check" ] && [ ! "$checkexclude" ]; then
    # No options just run
    cis
  elif [ -z "$check" ]; then
    # No check defined but excludes defined set to calls in cis() function
    check=$(sed -ne "/cis() {/,/}/{/{/d; /}/d; p}" functions/functions_lib.sh)
  fi

  for c in $(echo "$check" | sed "s/,/ /g"); do
    if ! command -v "$c" 2>/dev/null 1>&2; then
      echo "Check \"$c\" doesn't seem to exist."
      continue
    fi
    if [ -z "$checkexclude" ]; then
      # No excludes just run the checks specified
      "$c"
    else
      # Exludes specified and check exists
      checkexcluded="$(echo ",$checkexclude" | sed -e 's/^/\^/g' -e 's/,/\$|/g' -e 's/$/\$/g')"

      if echo "$c" | grep -E "$checkexcluded" 2>/dev/null 1>&2; then
        # Excluded
        continue
      elif echo "$c" | grep -vE 'check_[0-9]|check_[a-z]' 2>/dev/null 1>&2; then
        # Function not a check, fill loop_checks with all check from function
        loop_checks="$(sed -ne "/$c() {/,/}/{/{/d; /}/d; p}" functions/functions_lib.sh)"
      else
        # Just one check
        loop_checks="$c"
      fi

      for lc in $loop_checks; do
        if echo "$lc" | grep -vE "$checkexcluded" 2>/dev/null 1>&2; then
          # Not excluded
          "$lc"
        fi
      done
    fi
  done

  if [ -n "${globalRemediation}" ] && [ "$printremediation" = "1" ]; then
    logit "\n\n${bldylw}Section B - Remediation measures${txtrst}"
    logit "${globalRemediation}"
  fi

  logit "\n\n${bldylw}Section C - Score${txtrst}\n"
  info "Checks: $totalChecks"
  info "Score: $currentScore\n"

  endjson "$totalChecks" "$currentScore" "$(date +%s)"
}

main "$@"
