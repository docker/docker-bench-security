#!/bin/bash

bldred='\033[1;31m' # Bold Red
bldgrn='\033[1;32m' # Bold Green
bldblu='\033[1;34m' # Bold Blue
bldylw='\033[1;33m' # Bold Yellow
txtrst='\033[0m'

if [ -n "$nocolor" ] && [ "$nocolor" = "nocolor" ]; then
  bldred=''
  bldgrn=''
  bldblu=''
  bldylw=''
  txtrst=''
fi

logit () {
  printf "%b\n" "$1" | tee -a "$logger"
}

info () {
  local infoCountCheck
  local OPTIND c
  while getopts c args
  do
    case $args in
    c) infoCountCheck="true" ;;
    *) exit 1 ;;
    esac
  done
  if [ "$infoCountCheck" = "true" ]; then
    printf "%b\n" "${bldblu}[INFO]${txtrst} $2" | tee -a "$logger"
    totalChecks=$((totalChecks + 1))
    return
  fi
  printf "%b\n" "${bldblu}[INFO]${txtrst} $1" | tee -a "$logger"
}

pass () {
  local passScored
  local passCountCheck
  local OPTIND s c
  while getopts sc args
  do
    case $args in
    s) passScored="true" ;;
    c) passCountCheck="true" ;;
    *) exit 1 ;;
    esac
  done
  if [ "$passScored" = "true" ] || [ "$passCountCheck" = "true" ]; then
    printf "%b\n" "${bldgrn}[PASS]${txtrst} $2" | tee -a "$logger"
    totalChecks=$((totalChecks + 1))
  fi
  if [ "$passScored" = "true" ]; then
    currentScore=$((currentScore + 1))
  fi
  if [ "$passScored" != "true" ] && [ "$passCountCheck" != "true" ]; then
    printf "%b\n" "${bldgrn}[PASS]${txtrst} $1" | tee -a "$logger"
  fi
}

warn () {
  local warnScored
  local OPTIND s
  while getopts s args
  do
    case $args in
    s) warnScored="true" ;;
    *) exit 1 ;;
    esac
  done
  if [ "$warnScored" = "true" ]; then
    printf "%b\n" "${bldred}[WARN]${txtrst} $2" | tee -a "$logger"
    totalChecks=$((totalChecks + 1))
    currentScore=$((currentScore - 1))
    return
  fi
  printf "%b\n" "${bldred}[WARN]${txtrst} $1" | tee -a "$logger"
}

note () {
  local noteCountCheck
  local OPTIND c
  while getopts c args
  do
    case $args in
    c) noteCountCheck="true" ;;
    *) exit 1 ;;
    esac
  done
  if [ "$noteCountCheck" = "true" ]; then
    printf "%b\n" "${bldylw}[NOTE]${txtrst} $2" | tee -a "$logger"
    totalChecks=$((totalChecks + 1))
    return
  fi
  printf "%b\n" "${bldylw}[NOTE]${txtrst} $1" | tee -a "$logger"
}

yell () {
  printf "%b\n" "${bldylw}$1${txtrst}\n"
}

beginjson () {
  printf "{\n  \"dockerbenchsecurity\": \"%s\",\n  \"start\": %s,\n  \"tests\": [" "$1" "$2" | tee "$logger.json" 2>/dev/null 1>&2
}

endjson (){
  printf "\n  ],\n  \"checks\": %s,\n  \"score\": %s,\n  \"end\": %s\n}" "$1" "$2" "$3" | tee -a "$logger.json" 2>/dev/null 1>&2
}

logjson (){
  printf "\n  \"%s\": \"%s\"," "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
}

SSEP=
SEP=
startsectionjson() {
  printf "%s\n    {\n      \"id\": \"%s\",\n      \"desc\": \"%s\",\n      \"results\": [" "$SSEP" "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
  SEP=
  SSEP=","
}

endsectionjson() {
  printf "\n      ]\n    }" | tee -a "$logger.json" 2>/dev/null 1>&2
}

starttestjson() {
  printf "%s\n        {\n          \"id\": \"%s\",\n          \"desc\": \"%s\",\n          " "$SEP" "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
  SEP=","
}

log_to_json() {
  if [ $# -eq 1 ]; then
    printf "\"result\": \"%s\"" "$1" | tee -a "$logger.json" 2>/dev/null 1>&2
    return
  fi
  if [ $# -eq 2 ] && [ $# -ne 1 ]; then
    # Result also contains details
    printf "\"result\": \"%s\",\n          \"details\": \"%s\"" "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
    return
  fi
  # Result also includes details and a list of items. Add that directly to details and to an array property "items"
  # Also limit the number of items to $limit, if $limit is non-zero
  truncItems=$3
  if [ "$limit" != 0 ]; then
    truncItems=""
    ITEM_COUNT=0
    for item in $3; do
      truncItems="$truncItems $item"
      ITEM_COUNT=$((ITEM_COUNT + 1));
      if [ "$ITEM_COUNT" == "$limit" ]; then
        truncItems="$truncItems (truncated)"
        break;
      fi
    done
  fi
  itemsJson=$(printf "[\n            "; ISEP=""; ITEMCOUNT=0; for item in $truncItems; do printf "%s\"%s\"" "$ISEP" "$item"; ISEP=","; done; printf "\n          ]")
  printf "\"result\": \"%s\",\n          \"details\": \"%s: %s\",\n          \"items\": %s" "$1" "$2" "$truncItems" "$itemsJson" | tee -a "$logger.json" 2>/dev/null 1>&2
}

logcheckresult() {
  # Log to JSON
  log_to_json "$@"

  # Log remediation measure to JSON
  if [ -n "$remediation" ] && [ "$1" != "PASS" ] && [ "$printremediation" = "1" ]; then
    printf ",\n          \"remediation\": \"%s\"" "$remediation" | tee -a "$logger.json" 2>/dev/null 1>&2
    if [ -n "$remediationImpact" ]; then
      printf ",\n          \"remediation-impact\": \"%s\"" "$remediationImpact" | tee -a "$logger.json" 2>/dev/null 1>&2
    fi
  fi
  printf "\n        }" | tee -a "$logger.json" 2>/dev/null 1>&2

  # Save remediation measure for print log to stdout
  if [ -n "$remediation" ] && [ "$1" != "PASS" ]; then
    if [ -n "${checkHeader}" ]; then
      if [ -n "${addSpaceHeader}" ]; then
        globalRemediation="${globalRemediation}\n"
      fi
      globalRemediation="${globalRemediation}\n${bldblu}[INFO]${txtrst} ${checkHeader}"
      checkHeader=""
      addSpaceHeader="1"
    fi
    globalRemediation="${globalRemediation}\n${bldblu}[INFO]${txtrst} ${id} - ${remediation}"
    if [ -n "${remediationImpact}" ]; then
      globalRemediation="${globalRemediation} Remediation Impact: ${remediationImpact}"
    fi
  fi
}
