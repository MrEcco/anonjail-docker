#!/bin/bash
# set -x
set -e

# Hook the bash!
if [[ "${1}" == "bash" ]]
then
   shift
   exec /bin/bash $@
fi

### Google defaults
export DNS_OVER_HTTPS_IP=${DNS_OVER_HTTPS_IP:-"8.8.8.8"}
export DNS_OVER_HTTPS_DOMAIN=${DNS_OVER_HTTPS_DOMAIN:-"dns.google"}

### Cloudflare defaults
# export DNS_OVER_HTTPS_IP=${DNS_OVER_HTTPS_IP:-"1.1.1.1"}
# export DNS_OVER_HTTPS_DOMAIN=${DNS_OVER_HTTPS_DOMAIN:-"cloudflare-dns.com"}

### You can use your own or any other DOH provider: just provide
### valid DNS_OVER_HTTPS_IP and DNS_OVER_HTTPS_DOMAIN. Its DOH
### implementation strictly verify TLS connection, and
### DNS_OVER_HTTPS_DOMAIN must be in CN or SANs of server TLS
### cert. You can use this command to find actual cersificate CN:
###
### echo | openssl s_client -no_ssl3 -tlsextdebug -crlf -4 -connect ${DNS_OVER_HTTPS_IP}:443 2>&1 | grep depth=0 | sed "s/^.*CN = //g"
###

echo Using DOH: ${DNS_OVER_HTTPS_DOMAIN} by ${DNS_OVER_HTTPS_IP}

PROXYCHAINS=""
if [[ "${DNS_OVER_HTTPS_SOCKS5}" != "" ]]
then
   echo "socks5 ${DNS_OVER_HTTPS_SOCKS5}" | tr ':' ' ' >> /etc/proxychains/proxychains.conf
   PROXYCHAINS="/usr/bin/proxychains4 -f /etc/proxychains/proxychains.conf"
   /usr/local/bin/strict.py
   echo Using PROXYCHAINS: ${DNS_OVER_HTTPS_SOCKS5}
fi


exec ${PROXYCHAINS} /usr/bin/doh-stub --listen-port 53 --listen-address 0.0.0.0 --port 443 --remote-address ${DNS_OVER_HTTPS_IP} --domain ${DNS_OVER_HTTPS_DOMAIN} 
