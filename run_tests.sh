#!/bin/bash

. ./generate_tests.sh
. ./config/0_config.sh

TEST_RESULTS=$BENCH_ROOT/results

# make result folder (inside VOLUME)
# mkdir -p $TEST_RESULTS
# generate all tests: copy host and daemon level tests and generate container level tests for running containers
# generate_all_tests
# run bats with all tests or passed tests
# bats $TEST_ROOT >

#Set Script Name variable
SCRIPT="run_tests.sh"

#Initialize variables to default values.
OPT_FORMAT="t"
OPT_OUTPUT=$TEST_RESULTS
OPT_RESULTS=1

#Set fonts for Help.
if [ -e "/usr/bin/tput" ]; then
  BOLD=$(tput bold)
  REV=$(tput smso)
  NORM=$(tput sgr0)
else
  BOLD=""
  REV=""
  NORM=""
fi

#Help function
HELP() {
  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}${NORM}"\\n
  echo -e "Basic usage: ${BOLD}$SCRIPT [-c] [-p|-t] [-o path] <test> [<test> ...]${NORM}"\\n
  echo -e "Command line switches are optional. The following switches are recognized."
  echo -e "${REV}-c${NORM}  --Displays number of tests. No further functions are performed."
  echo -e "${REV}-g${NORM}  --Generates all CIS Bats tests without execution. No further functions are performed."
  echo -e "${REV}-p${NORM}  --Show results in pretty format."
  echo -e "${REV}-t${NORM}  --Show results in TAP format. This is the default format."
  echo -e "${REV}-r${NORM}  --Create test results files: ${BOLD}tests_<timestamp>.tap${NORM} in test result folder."
  echo -e "${REV}-o${NORM}  --Specify test result folder. Default to ${BOLD}$TEST_RESULTS${NORM}."
  echo -e "${REV}-h${NORM}  --Displays this help message. No further functions are performed."\\n
  echo -e "Example: ${BOLD}$SCRIPT -t -o $TEST_RESULTS${NORM}"\\n
  exit 1
}

#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
if [ "$NUMARGS" -eq 0 ]; then
  HELP
fi

### Start getopts code ###

#Parse command line flags
while getopts o:rptcgh FLAG; do
  case $FLAG in
    o)  # output test results into specified folder
      OPT_OUTPUT=$OPTARG
      ;;
    p)  # output test results in TAP format
      OPT_FORMAT="p"
      ;;
    t)  # output test results in pretty format
      OPT_FORMAT="t"
      ;;
    r)  # save test results into file
      OPT_RESULTS=0
      ;;
    c)  # count tests
      if [ -d "$TEST_ROOT" ]; then
        echo -e "There are ${BOLD}$(bats "${TEST_ROOT}" -c)${NORM} tests in ${BOLD}${TEST_ROOT}${NORM}"
      else
        echo -e "No tests found, run ${BOLD}${SCRIPT}${NORM} with ${REV}-g${NORM} option first."
      fi
      exit 1
      ;;
    g)  # genetate all Bats tests: copy tests and generate tests (per container) from templates
      generate_all_tests
      exit 1
      ;;
    h)  #show help
      HELP
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      HELP
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

### End getopts code ###

### Run Bats tests ###

TESTS="${TEST_ROOT}"
if [ ! -d "${TEST_ROOT}" ]; then # generate tests if needed
  generate_all_tests
fi

if [ $# -ne 0 ]; then # get tests from command line
  TESTS=$*
fi

if [ ${OPT_RESULTS} -eq 0 ]; then # run tests and [create test result file]
  if [ ! -d "$OPT_OUTPUT" ]; then
    mkdir -p "$OPT_OUTPUT"
  fi
  bats "${TESTS}" -${OPT_FORMAT} > "${OPT_OUTPUT}/tests_$(date +%s).tap"
else
  bats "${TESTS}" -${OPT_FORMAT}
fi

exit 0
