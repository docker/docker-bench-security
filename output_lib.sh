bldred='\033[1;31m'
bldgrn='\033[1;32m'
bldblu='\033[1;34m'
bldylw='\033[1;33m' # Yellow
txtrst='\033[0m'

logit () {
  printf "$1\n" | tee -a $logger
}

info () {
  printf '%b' "${bldblu}[INFO]${txtrst} $1\n" | tee -a $logger
}

pass () {
  printf '%b' "${bldgrn}[PASS]${txtrst} $1\n" | tee -a $logger
}

warn () {
  printf '%b' "${bldred}[WARN]${txtrst} $1\n" | tee -a $logger
}

yell () {
  printf '%b' "${bldylw}$1${txtrst}\n"
}
