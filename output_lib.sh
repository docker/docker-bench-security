#!/bin/sh

if [ -n "$nocolor" ] && [ "$nocolor" = "nocolor" ]; then
  bldred=''
  bldgrn=''
  bldblu=''
  bldylw=''
  txtrst=''
else
  bldred='\033[1;31m'
  bldgrn='\033[1;32m'
  bldblu='\033[1;34m'
  bldylw='\033[1;33m' # Yellow
  txtrst='\033[0m'
fi

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

beginjson () {
  printf "{\n  \"dockerbenchsecurity\": \"%s\",\n  \"start\": %s,\n  \"tests\": [" "$1" "$2" | tee "$logger.json" 2>/dev/null 1>&2
}

endjson (){
  printf "\n  ], \"checks\": %s, \"score\": %s, \"end\": %s \n}\n" "$1" "$2" "$3" | tee -a "$logger.json" 2>/dev/null 1>&2
}

logjson (){
  printf "\n  \"%s\": \"%s\"," "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
}

SSEP=
SEP=
startsectionjson() {
  printf "%s\n    {\"id\": \"%s\", \"desc\": \"%s\",  \"results\": [" "$SSEP" "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
  SEP=
  SSEP=","
}

endsectionjson() {
  printf "\n    ]}" | tee -a "$logger.json" 2>/dev/null 1>&2
}

starttestjson() {
  printf "%s\n      {\"id\": \"%s\", \"desc\": \"%s\", " "$SEP" "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
  SEP=","
}

resulttestjson() {
  if [ $# -eq 1 ]; then
      printf "\"result\": \"%s\"}" "$1" | tee -a "$logger.json" 2>/dev/null 1>&2
  elif [ $# -eq 2 ]; then
      # Result also contains details
      printf "\"result\": \"%s\", \"details\": \"%s\"}" "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
  else
      # Result also includes details and a list of items. Add that directly to details and to an array property "items"
      # Also limit the number of items to $limit, if $limit is non-zero
      if [ $limit != 0 ]; then
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
      else
        truncItems=$3
      fi
      itemsJson=$(printf "["; ISEP=""; ITEMCOUNT=0; for item in $truncItems; do printf "%s\"%s\"" "$ISEP" "$item"; ISEP=","; done; printf "]")
      printf "\"result\": \"%s\", \"details\": \"%s: %s\", \"items\": %s}" "$1" "$2" "$truncItems" "$itemsJson" | tee -a "$logger.json" 2>/dev/null 1>&2
  fi
}
