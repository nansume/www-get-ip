#!/bin/sh
# File: /bin/test-myip-urls
# Desc: Checking requests for multiple myip sites from the list.
# Usage: test-myip-urls /etc/getip-url.conf

F=${1:?required: test-myip-urls </etc/getip-url.conf>}
LOG="/tmp/test-urls.log"

[ -w "${LOG}" ] && > "${LOG:?}"
[ -x "www-get-ip.sh" ] && {
	PATH="${PATH}${PATH:+:}./"
	[ -x "www-get-ip" ] || ln -s www-get-ip.sh www-get-ip
}

N=0
{
while IFS= read -r X; do
  X=${X%%#*}
  X="${X%${X##*[![:space:]]}}"
  if [ -n "${X}" ]; then
    printf '%s\n' "www-get-ip -g '${X}'"
    www-get-ip -g "${X}" && N=$(expr "0${N}" + '1')
    printf '\n'
    usleep 200000
  fi
done < ${F}


[ "${N}" -gt '0' ] &&
printf '%s\n' "Success: ${N} requests... ok"

} 2>&1 | tee -a ${LOG}
