#!/bin/sh
# File: /bin/test-myip-rand
# Desc: Checking requests for multiple myip sites from the list.
# Usage: test-myip-rand /etc/getip-url.conf 4
set -e -u -f

IFS="$(printf '\n\t') "
F=${1:?required: test-myip-rand </etc/getip-url.conf>}
NMAX=${2:?required: number max requests}
LOG="/tmp/test-myip-rand.log"

[ -w "${LOG:?}" ] || LOG="test-myip-rand.log"
> "${LOG}"

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
    www-get-ip -v -f ${F}; N=$(expr "0${N}" + '1')
    printf '\n'
    sleep 1
    [ "0${N}" -ge "0${NMAX}" ] && break
  fi
done < ${F}


[ "${N}" -gt '0' ] &&
printf '%s\n' "Success: ${N} requests... ok"

} 2>&1 | tee -a ${LOG}
