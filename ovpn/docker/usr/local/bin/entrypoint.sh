#!/bin/bash
# set -x
set -e

# Hook the bash!
if [[ "${1}" == "bash" ]]
then
   shift
   exec /bin/bash $@
fi

function containerd_devfs_fix {
   # Idempotent
   mkdir -p /dev/net
   if [ ! -c /dev/net/tun ]; then
      mknod /dev/net/tun c 10 200
   fi
}

PROXYCHAINS=""
if [[ "${OVPN_SOCKS5}" != "" ]]
then
   echo "socks5 ${OVPN_SOCKS5}" | tr ':' ' ' >> /etc/proxychains/proxychains.conf
   PROXYCHAINS="/usr/bin/proxychains4 -f /etc/proxychains/proxychains.conf"
   echo Using PROXYCHAINS: ${DNS_OVER_HTTPS_SOCKS5}
fi

${PROXYCHAINS} /usr/local/bin/autovpn-vpngate.py --proto tcp > /etc/openvpn/vpngate.conf

######################## Options  ########################
echo >> /etc/openvpn/vpngate.conf
# echo 'server-poll-timeout 30' >> /etc/openvpn/vpngate.conf
# echo 'tls-timeout 30' >> /etc/openvpn/vpngate.conf
echo 'connect-timeout 30' >> /etc/openvpn/vpngate.conf
echo 'connect-retry 1' >> /etc/openvpn/vpngate.conf
echo 'connect-retry-max 1' >> /etc/openvpn/vpngate.conf

######################## Security ########################
# Drop root privilegies
echo >> /etc/openvpn/vpngate.conf
echo 'user openvpn' >> /etc/openvpn/vpngate.conf
echo 'group openvpn' >> /etc/openvpn/vpngate.conf

# Avoid unsafe pushed configuration parameters
echo >> /etc/openvpn/vpngate.conf
echo 'pull-filter ignore "dhcp-option"' >> /etc/openvpn/vpngate.conf
echo 'pull-filter ignore "route "' >> /etc/openvpn/vpngate.conf
echo 'pull-filter ignore "setenv "' >> /etc/openvpn/vpngate.conf

######################## Proxying ########################
if [[ "${OVPN_SOCKS5}" != "" ]]
then
   echo >> /etc/openvpn/vpngate.conf
   echo "socks-proxy ${OVPN_SOCKS5}" | tr ':' ' ' >> /etc/openvpn/vpngate.conf
fi

# Fix devfs in containerd
containerd_devfs_fix

/sbin/iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
/sbin/iptables -t filter -N strict
/sbin/iptables -t filter -N strict_anon
/sbin/iptables -t filter -A strict -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -t filter -A strict -j DROP
/sbin/iptables -t filter -A strict_anon -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -t filter -A strict_anon -d 10.0.0.0/8 -j ACCEPT
/sbin/iptables -t filter -A strict_anon -d 192.168.0.0/16 -j ACCEPT
/sbin/iptables -t filter -A strict_anon -d 172.16.0.0/12 -j ACCEPT
/sbin/iptables -t filter -A strict_anon -d 169.254.0.0/16 -j ACCEPT
/sbin/iptables -t filter -A strict_anon -d 100.64.0.0/10 -j ACCEPT
/sbin/iptables -t filter -A strict_anon -j DROP
/sbin/iptables -t filter -A INPUT -i tun0 -j strict
/sbin/iptables -t filter -A OUTPUT -o eth0 -j strict_anon
/sbin/iptables -t filter -A FORWARD -i eth0 -o tun0 -j ACCEPT
/sbin/iptables -t filter -A FORWARD -i tun0 -o eth0 -j strict
/sbin/iptables -t filter -A FORWARD -o eth0 -j strict_anon

exec /usr/sbin/openvpn --config /etc/openvpn/vpngate.conf
