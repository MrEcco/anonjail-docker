#!/bin/bash
# set -x
set -e

# Hook the bash!
if [[ "${1}" == "bash" ]]
then
   shift
   exec /bin/bash $@
fi

############################ Proxying ############################
### Tor will use this proxies for connect to any entry/relay/bridge)
PROXY_CONFIGURED="false"

if [[ "${PROXY_CONFIGURED}" != "true" ]]
then
   # Configure socks5 client if present
   if [[ $(echo ${!TOR_SOCKS5_@} | tr ' ' '\n' | egrep -v "^$" | wc -l) -gt 0 ]]
   then
      echo Using SOCKS5 proxy for connecting to TOR
      for socks5 in ${!TOR_SOCKS5_@}
      do
         socks5_arg=$(echo ${socks5} | sed "s/TOR_SOCKS5_//g")
         socks5_value=$(eval 'echo $'${socks5})
         if [[ "${socks5_arg}" == "PROXY" ]]
         then
            echo "Socks5Proxy ${socks5_value}" >> /etc/tor/torrc
         fi
         if [[ "${socks5_arg}" == "PROXY_USERNAME" ]]
         then
            echo "Socks5ProxyUsername ${socks5_value}" >> /etc/tor/torrc
         fi
         if [[ "${socks5_arg}" == "PROXY_PASSWORD" ]]
         then
            echo "Socks5ProxyPassword ${socks5_value}" >> /etc/tor/torrc
         fi
      done
      PROXY_CONFIGURED="true"
   fi
else
   if [[ $(echo ${!TOR_SOCKS5_@} | tr ' ' '\n' | egrep -v "^$" | wc -l) -gt 0 ]]
   then
      echo WARNING: Using few types of proxy can case unexpected behaviour!
   fi
fi

if [[ "${PROXY_CONFIGURED}" != "true" ]]
then
   # Configure https client if present
   if [[ $(echo ${!TOR_HTTPS_@} | tr ' ' '\n' | egrep -v "^$" | wc -l) -gt 0 ]]
   then
      echo Using HTTPS proxy for connecting to TOR
      for https in ${!TOR_HTTPS_@}
      do
         https_arg=$(echo ${https} | sed "s/TOR_HTTPS_//g")
         https_value=$(eval 'echo $'${https})
         if [[ "${https_arg}" == "PROXY" ]]
         then
            echo "HTTPSProxy ${https_value}" >> /etc/tor/torrc
         fi
         if [[ "${https_arg}" == "PROXY_AUTHENTICATOR" ]]
         then
            echo "HTTPSProxyAuthenticator ${https_value}" >> /etc/tor/torrc
         fi
      done
      PROXY_CONFIGURED="true"
   fi
else
   if [[ $(echo ${!TOR_HTTPS_@} | tr ' ' '\n' | egrep -v "^$" | wc -l) -gt 0 ]]
   then
      echo WARNING: Using few types of proxy can case unexpected behaviour!
   fi
fi

if [[ "${PROXY_CONFIGURED}" != "true" ]]
then
   # Configure http client if present
   if [[ $(echo ${!TOR_HTTP_@} | tr ' ' '\n' | egrep -v "^$" | wc -l) -gt 0 ]]
   then
      echo WARNING: Using HTTP proxy is DEPRECATED! Use HTTPS proxy instead!
      echo Using HTTP proxy for connecting to TOR
      for http in ${!TOR_HTTP_@}
      do
         http_arg=$(echo ${http} | sed "s/TOR_HTTP_//g")
         http_value=$(eval 'echo $'${http})
         if [[ "${http_arg}" == "PROXY" ]]
         then
            echo "HTTPProxy ${http_value}" >> /etc/tor/torrc
         fi
         if [[ "${http_arg}" == "PROXY_AUTHENTICATOR" ]]
         then
            echo "HTTPProxyAuthenticator ${http_value}" >> /etc/tor/torrc
         fi
      done
      PROXY_CONFIGURED="true"
   fi
else
   if [[ $(echo ${!TOR_HTTP_@} | tr ' ' '\n' | egrep -v "^$" | wc -l) -gt 0 ]]
   then
      echo WARNING: Using few types of proxy can case unexpected behaviour!
   fi
fi

############################ Bridging ############################
# Configure bridges if present
if [[ $(echo ${!TOR_BRIDGE@} | tr ' ' '\n' | egrep -v "^$" | wc -l) -gt 0 ]]
then
   echo UseBridges 1 >> /etc/tor/torrc
   for bridge in ${!TOR_BRIDGE@}
   do
      bridge_name=$(echo ${bridge} | sed "s/TOR_BRIDGE_//g")
      bridge_def=$(eval 'echo $'${bridge})
      echo Adding bridge: ${bridge_def}
      echo "Bridge ${bridge_def}" >> /etc/tor/torrc
   done
fi

exec /usr/bin/tor $@
