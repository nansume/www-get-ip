#!/bin/sh
# File: /bin/router-getip
# Usage: EXTIP=$(router-getip)
# Example: router-getip -a admin -p $(cat ${PASSWD_FILE})
# Depend: wget
set -e -u -f

IFS="$(printf '\n\t')"
OLDIFS=${IFS}
runuser="nobody"
admin_user="admin"

print_progver() {
  printf '%s\n' "router-getip 0.0.1a written on Jan 12 2026 19:38:45"
  printf '%s\n' "Copyright 2026 Artjom Slepnjov (shellgen@uncensored.citadel.org)"
}

print_help() {
  print_progver; printf '\n'
  cat >&2 <<_EOF_
Usage: ${0##*/} -v -u USER -p PORT

Options:
  -u  user (drop privileges)
  -a  admin <user>
  -p  pass
  -v  verbose (show uri)
  -V  Print version information and exit
  -h  Print usage help and exit
_EOF_

exit 1
}

filter_ipaddr(){
  sed \
    -e 's/\(^\|[^0-9.]\)0\.0\.0\.0\([^0-9.]\|$\)//' \
    -e 's/\(^\|[^0-9.]\)255\.255\.255\.0\([^0-9.]\|$\)//' \
    -e 's/\(^\|[^0-9.]\)127\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\([^0-9.]\|$\)//' \
    -e 's/\(^\|[^0-9.]\)192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}\([^0-9.]\|$\)//g'
}

case $(id -un) in
  'root')
    IFS=" " ARG=${@}; IFS=${OLDIFS}
    while [ x"${1-}" != x ]; do
      case ${1-} in
        -u) runuser=${2:?required user}; shift;;
        -h) print_help;;
      esac
      shift
    done
    [ -n "${runuser-}" ] || exit 1

    IFS="${IFS} "; su ${runuser} -c "${0##*/} ${ARG}";
    exit $?
  ;;
esac

while [ x"${1-}" != x ]; do
  case $1 in
    -u) shift;;

    -a) admin_user=${2:?required admin}
        shift;;

    -p) admin_pass=${2:?required pass}
        shift;;

    -v) verbose="1";;

    -V) print_progver
        exit 0;;

    -h) print_help;;

     *) print_help;;
  esac
  shift
done

admin_pass=${admin_pass:?required pass}

set -- $(route -A inet -n)
set -- ${3#* }
set -- "${1#${1%%[![:space:]]*}}"
gw=${1%% *}  # gateway


# getpage.lua?pid=1002&nextpage=home_a_t.gch

set -- '\(25[0-5]\|2[0-4][0-9]\|[01]\?[0-9][0-9]\?\)' "[=/,{}<>\`\'\";]"
set -- "${1}" "${2}" "\(>\|^\|[[:blank:]]\|${2}\)" "\(<\|${2}\|[[:blank:]]\|$\)"

wget \
  -q \
  --post-data "action=login&Username=${admin_user}&Password=${admin_pass}" \
  -O - "http://${gw}/getpage.lua?pid=1005&nextpage=common_page/InternetReg_lua.lua" \
  2>&1 | filter_ipaddr |

grep -om1 "${3}${1}\.${1}\.${1}\.${1}${4}"
