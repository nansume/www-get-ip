#!/bin/sh
# File: /bin/www-get-ip 0755 root:root
# Name: get-www-ip | www-get-ip | get-remote-ip | get-ip | get-public-ip | external-ip | ext-ip
# Usage: www-get-ip -f /etc/getip-url.conf -u <user> -g <url>
# Sample: EXTIP=$(www-get-ip)
set -euf

print_help() {
  cat >&2 <<_EOF_
Usage: ${0##*/} -u USER -t TIMEOUT { -f CONF | -g URL }

Get public ip

        -u      user (drop privileges)
        -t      get timeout
        -f      Config file with urls
        -g      url (get url)
        -h      help
_EOF_

exit 1
}

case $(id -un) in
  'root')
		ARG=${@}
		while [ x"${1-}" != x ]; do
    	case ${1-} in
  			-u) userarg=${2:?required user}; shift;;
  			-h) print_help;;
			esac
			shift
		done
		[ -n "${userarg-}" ] || exit 1

		FS="${IFS} "; su ${userarg} -c "${0##*/} $(printf '%s ' ${ARG})";
		exit $?
	;;
esac

confarg=
url=
while [ x"${1-}" != x ]; do
  case $1 in
    -f) confarg=${2:?required configfile}
        shift;;

    -g) g_url=${2:?required url}
        shift;;

    -u) shift;;

    -t) g_timeout=${2:?required timeout}
    		shift;;

    -h) print_help;;

     *) print_help;;
  esac
  shift
done
[ -n "${confarg-}" ] || confarg="/etc/getip-url.conf"
[ -s "${confarg}" ] || [ -n "${g_url-}" ] || { printf '%s\n' "${confarg}: not found... error" >&2; exit;}
[ -n "${g_timeout-}" ] || g_timeout="8"


loadfile() {
  local NL="$(printf '\n\t')"; NL=${NL%?}
  local F=${1:?required: loadfile </etc/getip-url.conf>}
  local X

  set --
  while IFS= read -r X; do
    X=${X%%#*}
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

  set -- "${1}" ${2} ${3} "${4}" '3' '0'

  NUMRAND=$(tr -dc 0-9 < /dev/urandom | fold -w ${#3} | head -n 1)

  # expr ${RANDOM} % 80
  set -- "${1}" ${2} ${3} "${4}" $(expr "0${NUMRAND}" % ${3}) '0'

  IFS=${1}
  for X in ${4}; do
    set -- "${1}" ${2} ${3} "${4}" ${5} $(expr "0${6}" + '1')
    [ "${6}" -eq "${5}" ] || continue
    set -- "${1}" ${2} ${3} "${4}" ${5} ${6} "${X}"
    break
  done

  [ -n "${7}" ] && printf '%s\n' "${7}"  # URL
}

get_ip(){
  URL=${1:?} XURL=${1}

  UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0"
  REFERER=${URL}

  : ${UA:= }
  URL=${URL#*://}
  HOST=${URL%%/*}; : ${HOST:?}
  URL=${URL#$HOST}
  q=\"\'
  [ -n "${XURL-}" ] || XURL="http://${HOST}:80/${URL#/}"

  set --
  set -- "${1:+${1} }--header 'Host: ${HOST}'"
  set -- "${1:+${1} }--header 'User-Agent: ${UA-}'"
  set -- "${1:+${1} }--header 'Referer: ${REFERER:-${XURL}}'"
  set -- "${1:+${1} }-q -T ${g_timeout} -SO -"
  set -- "${1:+${1} }'${XURL}'"

  ulimit -d '100'

  { eval wget ${1} 2>&1; printf '\n';} 2>/dev/null | while IFS= read -r S; do
    S=$(printf '%s' "${S}" | sed "s/&#46;/./g;s/\(&quot;\|,\)/ /g" 2>/dev/null | grep -om1 '\(>\|^\|[[:blank:]]\|["$q"]\)\(25[0-5]\|2[0-4][0-9]\|[01]\?[0-9][0-9]\?\)\.\(25[0-5]\|2[0-4][0-9]\|[01]\?[0-9][0-9]\?\)\.\(25[0-5]\|2[0-4][0-9]\|[01]\?[0-9][0-9]\?\)\.\(25[0-5]\|2[0-4][0-9]\|[01]\?[0-9][0-9]\?\)\(<\|["$q"]\|[[:blank:]]\|$\)' 2>/dev/null
    )
    [ -n "${S}" ] && { set -- ${S}; printf '%s\n' "${1}"; break ;}
  done
}


set -- '7' '0'

EXTIP=
url=${g_url-}
until [ -n "${EXTIP-}" ]; do
  if [ "0${2}" -gt "${1}" ]; then
    break
  elif [ -n "${g_url-}" ]; then
    [ "0${2}" -gt "3" ] && break
  else
    url=$(seturl ${confarg:?required filename})
  fi
  EXTIP=$(get_ip ${url:?required url} || exit 0)
  EXTIP="${EXTIP%${EXTIP##*[0-9.]}}"
  EXTIP="${EXTIP#${EXTIP%%[0-9.]*}}"
  usleep 200000
  set -- ${1} $(expr "0${2}" + 1)
done

printf %s\\n "${EXTIP:?required ip address}"
