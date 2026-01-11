#!/bin/sh
# File: /bin/www-get-ip 0755 root:root
# ---------------------------------------------------------------------------------------------
# Copyright (C) 2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# ---------------------------------------------------------------------------------------------
# Name: get-www-ip | www-get-ip | get-remote-ip | get-ip | get-public-ip | external-ip | ext-ip
# Usage: www-get-ip -v -f /etc/getip-url.conf -u <user> -g <url>
# Example: EXTIP=$(www-get-ip) | EXTIP=$(www-get-ip -u nobody)
# Compatible: replace `[!` to `[^`
# ---------------------------------------------------------------------------------------------
# Date: 2025-12-13 20:25 UTC - last change
# ---------------------------------------------------------------------------------------------
set -e -u -f

IFS="$(printf '\n\t') "
OLDIFS=${IFS}
verbose="0"
dry_run="0"
confarg=
url=

print_progver() {
  printf '%s\n' "WWW-Get-IP 0.0.1a written on Dec 13 2025 20:25:03"
  printf '%s\n' "Copyright 2025 Artjom Slepnjov (shellgen@uncensored.citadel.org)"
}

print_help() {
  print_progver; printf '\n'
  cat >&2 <<_EOF_
Usage: ${0##*/} -v -u USER -t TIMEOUT { -f CONF | -g URL }

Options:
        -u      user (drop privileges)
        -t      request timeout
        -f      Config file with urls
        -g      url (get url)
        -v      verbose (show url)
        -n      dry-run - no fetch, only show a number and url
        -V      Print version information and exit
        -h      Print usage help and exit
_EOF_

exit 1
}

case $(id -un) in
  'root')
		IFS=" " ARG=${@}; IFS=${OLDIFS}
		while [ x"${1-}" != x ]; do
    	case ${1-} in
  			-u) userarg=${2:?required user}; shift;;
  			-h) print_help;;
			esac
			shift
		done
		[ -n "${userarg-}" ] || exit 1

		su ${userarg} -c "${0##*/} ${ARG}";
		exit $?
	;;
esac

while [ x"${1-}" != x ]; do
  case $1 in
    -f) confarg=${2:?required configfile}
        shift;;

    -g) g_url=${2:?required url}
        shift;;

    -u) shift;;

    -t) g_timeout=${2#${2%%[!0-9]*}}
        [ -z "${2#${2%%[!0-9]*}}" ] || set --
        g_timeout=${2:?required timeout}
    		shift;;

    -v) verbose="1";;

		-n)	dry_run="1";;

		-V) print_progver
		    exit 0;;

    -h) print_help;;

     *) print_help;;
  esac
  shift
done
[ -n "${confarg-}" ] || confarg="/etc/getip-url.conf"
[ -s "${confarg}" ] || [ -n "${g_url-}" ] || { printf '%s\n' "${confarg}: not found... error" >&2; exit;}
[ -n "${g_timeout-}" ] || g_timeout="10"


decolorize(){ sed 's/\x1B\[[0-9;]\{1,8\}[A-Za-z]//g';}

filter_ipaddr(){
  # TODO: to take away script-tag (is there may be ip address)
  sed \
    -e '/^  Ip: [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$/d' \
    -e '/^  ServerIP: [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$/d' \
    -e '/^  X-Server-Ip: [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$/d' \
    -e 's/<!--[^>]*-->//g' \
    -e 's|__<script>[^>]*</script>__||g' \
    -e 's|<meta name=[^>]*/>||' \
    -e 's/\(^\|[^0-9.]\)0\.0\.0\.0\([^0-9.]\|$\)//' \
    -e 's/\(^\|[^0-9.]\)127\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\([^0-9.]\|$\)//' \
    -e 's/\(^\|[^0-9.]\)192\.0\.\(0\|2\)\.[0-9]\{1,3\}\([^0-9.]\|$\)//g' \
    -e 's/\(^\|[^0-9.]\)192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}\([^0-9.]\|$\)//g' \
    -e 's/\(^\|[^0-9.]\)10\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\([^0-9.]\|$\)//g' \
    -e 's/\(^\|[^0-9.]\)172\.\(1[6-9]\|2[0-9]\|3[01]\)\.[0-9]\{1,3\}\.[0-9]\{1,3\}\([^0-9.]\|$\)//g'
}

loadfile() {
  local NL="${IFS%${IFS#?}}"
  local F=${1:?required: loadfile </etc/getip-url.conf>}
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
  set -- "$(printf '\n\t')" ${1:?required: seturl </etc/getip-url.conf>}
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
  local IFS=${IFS}
  local XURL=${1:?}
  local UA="curl/7.54.1"  # useragent
  local ARGS

  IFS=","
  set -- "-q,-T,${g_timeout},-SO,-"
  set -- "${1},--header,User-Agent: ${UA}"
  set -- "${1},--header,Referer: ${XURL}"
  ARGS=${@}

  set -- '\(25[0-5]\|2[0-4][0-9]\|[01]\?[0-9][0-9]\?\)' "[=/,{}<>\`\'\";]"
  set -- "${1}" "${2}" "\(>\|^\|[[:blank:]]\|${2}\)" "\(<\|${2}\|[[:blank:]]\|$\)"

  ulimit -d 20000

  wget ${ARGS} -- "${XURL}" 2>&1 |

  decolorize | sed "s/&#46;/./g;s/\(&quot;\|,\)/ /g" 2>/dev/null | filter_ipaddr |

  grep -om1 "${3}${1}\.${1}\.${1}\.${1}${4}" 2>/dev/null |

  while IFS=' ' read -r S _; do
    IFS=${OLDIFS}; [ -n "${S-}" ] && { set -- ${S}; printf '%s\n' "${1}";}
  break; done
}

set -- '7' '0'

EXTIP=
url=${g_url-}
until [ -n "${EXTIP-}" ]; do
  if [ -n "${g_url-}" ]; then
    [ "0${2}" -gt "3" ] && break
  elif [ "0${2}" -gt "${1}" ]; then
    break
  elif [ "${dry_run:-0}" -eq '0' ]; then
    url=$(seturl ${confarg:?required filename})
  else
  	seturl ${confarg:?required filename}
  	exit 0
  fi
  if [ "${dry_run:-0}" -eq '0' ]; then
  	EXTIP=$(get_ip ${url:?required url} || exit 0)
  	EXTIP="${EXTIP%${EXTIP##*[0-9.]}}"
  	EXTIP="${EXTIP#${EXTIP%%[0-9.]*}}"  # it digits + dots
  	[ "${#EXTIP}" -le '15' ] || EXTIP=
  	[ "${#EXTIP}" -ge '7' ] || EXTIP=   # check length ip addr
  	[ -n "${EXTIP-}" ] || dd if=/dev/urandom bs=4096 count=2048 >/dev/null 2>&1  # delay
  fi
  set -- ${1} $(expr "0${2}" + 1)
done

[ "${verbose:-0}" -ne '0' ] && printf %s\\n "www-get-ip -g '${url:?}'"
printf %s\\n "${EXTIP:?required ip address}"
