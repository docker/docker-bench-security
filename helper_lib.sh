#!/bin/sh

# Returns the absolute path of a given string
abspath () { case "$1" in /*)printf "%s\n" "$1";; *)printf "%s\n" "$PWD/$1";; esac; }

# Compares versions of software of the format X.Y.Z
do_version_check() {
    [ "$1" = "$2" ] && return 10

    ver1front=$(printf "%s" "$1" | cut -d "." -f -1)
    ver1back=$(printf "%s" "$1" | cut -d "." -f 2-)
    ver2front=$(printf "%s" "$2" | cut -d "." -f -1)
    ver2back=$(printf "%s" "$2" | cut -d "." -f 2-)

    if [ "$ver1front" != "$1" ] || [ "$ver2front" != "$2" ]; then
        [ "$ver1front" -gt "$ver2front" ] && return 11
        [ "$ver1front" -lt "$ver2front" ] && return 9

        [ "$ver1front" = "$1" ] || [ -z "$ver1back" ] && ver1back=0
        [ "$ver2front" = "$2" ] || [ -z "$ver2back" ] && ver2back=0
        do_version_check "$ver1back" "$ver2back"
        return $?
    else
        [ "$1" -gt "$2" ] && return 11 || return 9
    fi
}

# Compares two strings and returns 0 if the second is a substring of the first
contains() {
    string="$1"
    substring="$2"
    if [ "${string#*$substring}" != "$string" ]
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

# Extracts all commandline args from all running processes named like the first parameter
get_command_line_args() {
    PROC="$1"

    for PID in $(pgrep -x -o "$PROC")
    do
        tr "\0" " " < /proc/"$PID"/cmdline
    done
}

# Set terminal colours used by functions in output_lib
set_colours() {

    case "$?" in
        none)
            bldred=
            bldgrn=
            bldblu=
            bldylw=
            txtrst=
            ;;
        default|*)
            bldred='\033[1;31m'
            bldgrn='\033[1;32m'
            bldblu='\033[1;34m'
            bldylw='\033[1;33m' # Yellow
            txtrst='\033[0m'
            ;;
    esac
}
