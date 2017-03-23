#!/bin/sh
bldred='\033[1;31m'
bldgrn='\033[1;32m'
bldblu='\033[1;34m'
bldylw='\033[1;33m' # Yellow
txtrst='\033[0m'

logit () {
  printf "%b\n" "$1" | tee -a "$logger"
}

info () {
  printf "%b\n" "${bldblu}[INFO]${txtrst} $1" | tee -a "$logger"
}

pass () {
  printf "%b\n" "${bldgrn}[PASS]${txtrst} $1" | tee -a "$logger"
}

warn () {
  printf "%b\n" "${bldred}[WARN]${txtrst} $1" | tee -a "$logger"
}

note () {
  printf "%b\n" "${bldylw}[NOTE]${txtrst} $1" | tee -a "$logger"
}

yell () {
  printf "%b\n" "${bldylw}$1${txtrst}\n"
}
