#!/bin/sh
# File: /bin/netdev-ip 0755 root:root
# Date: 2024-01-17 15:00 UTC - last change
set -e -u -f

IFS="$(printf '\n\t')"; IFS=${IFS%?}

get_netdev(){
  for NETDEV in $(route -n -A "inet") ''; do
    case ${NETDEV-} in
      '0.0.0.0 '*) break;;
    esac
  done
  [ -n "${NETDEV-}" ] && printf '%s\n' "${NETDEV##* }"
}

[ -n "${1-}" ] || set -- $(get_netdev)

for IP in $(ifconfig -a "${1:-eth0}") ''; do
  case ${IP} in
    *' addr:'*)
      IP=${IP#*addr: }  # match: inet6 addr: <ipv6addr>
      IP=${IP#*addr:}   # match: inet addr:<ipv4addr>
      IP=${IP%%/[0-9]*} # surely for ipv6 ?
      break
    ;;
  esac
done

[ -n "${IP}" ] && printf %s\\n "${IP%% *}"
