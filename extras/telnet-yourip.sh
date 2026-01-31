#!/bin/sh
# File: /bin/telnet-yourip
# Usage: EXTIP=$(telnet-yourip)
# Depend: telnet
set -e -u -f

IFS="$(printf '\n\t') "
OLDIFS=${IFS}
runuser="nobody"
confarg="/etc/telnet-yourip.conf"
port="587"
url=
verbose="0"
comm=

print_progver() {
  printf '%s\n' "telnet-yourip 0.0.1a written on Jan 11 2026 22:37:35"
  printf '%s\n' "Copyright 2026 Artjom Slepnjov (shellgen@uncensored.citadel.org)"
}

print_help() {
  print_progver; printf '\n'
  cat >&2 <<_EOF_
Usage: ${0##*/} -u USER -v { -f CONF | -g URL }

Options:
  -u  user (drop privileges)
  -f  Config file with urls
  -g  url:port (get url)
  -v  verbose (show uri)
  -V  Print version information and exit
  -h  Print usage help and exit
_EOF_

exit 1
}

loadfile() {
  local NL="${IFS%${IFS#?}}"
  local F=${1:?required: loadfile </etc/telnet-yourip.conf>}
  local X

  set --
  while IFS= read -r X; do
    X=${X%%#*}
    X="${X%${X##*[![:space:]]}}"
    [ -n "${X-}" ] || continue
    printf '%s' "${1:+${NL}}${X}"
    set -- "${X}"
  done < ${F}
}

seturl() {
  set -- "$(printf '\n\t')" ${1:?required: seturl </etc/telnet-yourip.conf>}
  set -- "${1%?}" ${2} '0' "$(loadfile ${2})"

  for X in ${4}; do
    set -- "${1}" ${2} $(expr "0${3}" + '1') "${4}"
  done

  set -- "${1}" ${2} ${3} "${4}" $(shuf -z -n '1' -i 1-${3}) '0'

  IFS=${1}
  for X in ${4}; do
    set -- "${1}" ${2} ${3} "${4}" ${5} $(expr "0${6}" + '1')
    [ "${6}" -eq "${5}" ] || continue
    set -- "${1}" ${2} ${3} "${4}" ${5} ${6} "${X}"
    break
  done

  if [ "${dry_run:-0}" -eq '0' ]; then
    [ -n "${7}" ] && printf '%s\n' "${7}"  # URL
  else
    [ -n "${7}" ] && printf '%s\n' "${5}: ${7}"
  fi
}

get_ip(){
  { printf '%s\n' "${2-}"; sleep 1;} | telnet "${1:?required url}" ${3:-587}
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

    su ${runuser} -c "${0##*/} ${ARG}";
    exit $?
  ;;
esac

while [ x"${1-}" != x ]; do
  case $1 in
    -f) confarg=${2:?required configfile}
        shift;;

    -g) url=${2:?required url}
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


[ -n "${url-}" ] || url=$(seturl ${confarg:?required filename})
port=${url##*:}; url=${url%:*}
[ -z "${url%%*/*}" ] && { IFS="/"; set -- ${url#*/}; IFS=" " comm=${@} IFS=${OLDIFS} ;}
url=${url%%/*}

[ "${verbose:-0}" -ne '0' ] &&
printf %s\\n "{ printf '%s\n' '${comm-}'; sleep 1;} | telnet '${url-}' '${port-}'"

get_ip "${url:?}" "${comm-}" ${port:?} |
while IFS= read -r S; do  # Here child proc.
  case ${S} in
    '250 '*'Hello'*)
      S=${S##* }; S=${S##*'['}; S=${S%%']'*}
      printf '%s\n' "${S}"
      exit 1
    ;;
  esac
done || exit 0

printf '%s\n' "${0##*/}: IPADDR: not found... error" >&2
exit 1