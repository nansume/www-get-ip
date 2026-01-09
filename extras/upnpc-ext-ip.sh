#!/bin/sh
# File: /bin/upnpc-ext-ip
# Usage: EXTIP=$(upnpc-ext-ip)
# Depend: upnpc, route, netcat
set -e -u -f

IFS="$(printf '\n\t')"
runuser="nobody"
port="80"

print_progver() {
  printf '%s\n' "upnpc-ext-ip 0.0.2a written on Jan 09 2026 19:57:54"
  printf '%s\n' "Copyright 2026 Artjom Slepnjov (shellgen@uncensored.citadel.org)"
}

print_help() {
  print_progver; printf '\n'
  cat >&2 <<_EOF_
Usage: ${0##*/} -v -u USER -p PORT

Options:
  -u  user (drop privileges)
  -p  port
  -v  verbose (show uri)
  -V  Print version information and exit
  -h  Print usage help and exit
_EOF_

exit 1
}

case $(id -un) in
  'root')
    ARG=${@}
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
    -p) g_port=${2:?required port}; port=${g_port}
        shift;;

    -u) shift;;

    -v) verbose="1";;

    -V) print_progver
        exit 0;;

    -h) print_help;;

     *) print_help;;
  esac
  shift
done

set -- $(route -A inet -n)
set -- ${3#* }
set -- "${1#${1%%[![:space:]]*}}"
gw=${1%% *}  # gateway

[ -z "${g_port-}" ] && { netcat -n -z ${gw:?} 52869 && port="52869";}  # FIX: for zte-router
UPNP_URI="http://${gw:?}:${port:?}/gatedesc.xml"

[ -n "${UPNP_URI:?required variable: <UPNP_URI>}" ] || exit
[ "${verbose:-0}" -ne '0' ] && printf '%s\n' "UPNP_URI='${UPNP_URI}'"

command upnpc -u "${UPNP_URI}" -l | while IFS= read -r S; do  # Here child proc.
  case ${S} in
    'ExternalIPAddress = '*)
      printf '%s\n' "${S##* }"
      exit 1
    ;;
  esac
done || exit 0

printf '%s\n' "${0##*/}: IPADDR: not found... error" >&2
exit 1