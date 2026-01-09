#!/bin/sh
# File: /bin/test-myip-urls
# Desc: Checking requests for multiple myip sites from the list.
# Usage: test-myip-urls /etc/getip-url.conf
# Example[file-rand-sort]: shuf ${file} > ${file}.new
set -e -u -f

IFS="$(printf '\n\t') "
F=${1:?required: test-myip-urls </etc/getip-url.conf>}
LOG="/tmp/test-urls.log"

[ -w "${LOG:?}" ] || LOG="test-urls.log"
> "${LOG}"

[ -x "www-get-ip.sh" ] && {
	PATH="${PATH}${PATH:+:}./"
	[ -x "www-get-ip" ] || ln -s www-get-ip.sh www-get-ip
}

N=0; E=0
{
while IFS= read -r X; do
  X=${X%%#*}
  X="${X%${X##*[![:space:]]}}"
  if [ -n "${X}" ]; then
    printf '%s\n' "www-get-ip -g '${X}'"
    ip=$(time -f %es www-get-ip -g "${X}") || { E=$(expr "0${E}" + '1'); continue;}
    [ "${myip-}" ] || myip=${ip}
    printf "${ip}\n\n"
    [ x"${myip}" = x"${ip}" ] || { E=$(expr "0${E}" + '1'); printf "this ip is not your... error\n" >&2; continue;}
    N=$(expr "0${N}" + '1')
    sleep 1
  fi
done < ${F}


[ "${N}" -gt '0' ] &&
printf '%s\n' "Success: ${N} requests... ok"

[ "${E}" -gt '0' ] &&
printf '%s\n' "Failed: ${E} requests... error"

} 2>&1 | tee -a ${LOG}
