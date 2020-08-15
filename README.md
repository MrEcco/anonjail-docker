# Anonymous Jail for Containers

[![License: CC0-1.0](https://licensebuttons.net/l/zero/1.0/80x15.png)](https://creativecommons.org/publicdomain/zero/1.0/)

This is proof-of-concept containerized application with stricted traffic anonimization.

System developed with concept of imposibility to escape the jail for traffic: this
provided by complex firewall configuration for each cgroup and network namespaces (aka
docker containers).

This jail ready for use with specific cases:

1. Jailed app spawn any IPv4 traffic and pass it through prepared anonymisation system.
This did not requre any additional configurations - it work from the box.

2. Jailed app can listen ports like any non-jailed, an its port available from its
docker network. For access from remote/external - use [socat](https://hub.docker.com/r/alpine/socat).

## How it work

Just using tor is not enought for some some task: it have problems to pass UDP traffic
via SOCKS5, or you cannot to use python-scappy to pass it via proxychains5. For avoid
its problems you can try to pass VPN over Tor. Its is it!

But on this way you can found few deanonimization problems: you must acquire credentials
of public VPN servers and get DNS record for its. For avoid any DNS-based deanonimization
this jail configure DNS-over-TLS proxy which pass traffic via tor, like VPN credentials.

**IMPORTANT NOTES!!!**

This jail ready for anonymize your traffic, but not your content! Use metadata removers
for your traffic for isolate content (try privoxy for HTTP or something like that).

## Configuration abilities

1. You can use bridges: just take few from https://bridges.torproject.org/. I recommend
to use bridges with obfs4 feature, but its rare thing and may not be present for any
timeslot. Just add envs `TOR_BRIDGE_<<<something>>>` and start container - it have
autoconfiguration capabilities.

2. Like a tor bridges, you can specify dedicated proxy. Use its variables: TOR_SOCKS5_PROXY,
TOR_SOCKS5_PROXY_USERNAME, TOR_SOCKS5_PROXY_PASSWORD, TOR_HTTPS_PROXY,
TOR_HTTPS_PROXY_AUTHENTICATOR, TOR_HTTP_PROXY, TOR_HTTP_PROXY_AUTHENTICATOR.

3. You can select DNS-over-HTTPS provider: use DNS_OVER_HTTPS_IP and DNS_OVER_HTTPS_DOMAIN.
DNS_OVER_HTTPS_DOMAIN must have VALID certificate which can be acquired by this command:

```bash
openssl s_client -no_ssl3 -tlsextdebug -crlf -4 -connect ${DNS_OVER_HTTPS_IP}:443 2>&1 | grep depth=0 | sed "s/^.*CN = //g"
```

4. You can specify dedicated SOCKS5 proxy for openvpn: use OVPN_SOCKS5. As you see, its
jail preconfigured for using tor (see docker-compose.yml).

5. You can use any other VPN which based on TCP traffic. Use proxychains5 for restrict
application which have no socks-proxying capabilities (but dont forget to check traffic
escaping - proxychains5 is not always work correct).

## Application in jail

This repository handle few basic images for your application: alpine, ubuntu, debian and
centos. All tested for its jail and, if you dont skip its entrypoints, its provide enought
reliability of anonimization: its remove default route gateway and insert its own, which
pass traffic via anonimization system.

Keep in mind: when you spawn container with bash (for reasearch Dockerfile for build your
own app, etc) your traffic ANONIMIZED NOW. And it can be too slow to use apk/apt/yum.
Anyway, you can use original docker image for reasearch and, after that, replace `FROM`
image.

## Helpers

### Tor activity visualization

Tor container have amazing ncurces-based UI. For use it, enter to tor container and do
this command:

```bash
nyx
```

### Speedtest

Reccomend to use it with Tor activity visualization (see before).

```bash
nslookup speedtest.tele2.net
# ip ro add ${ip_address_of_prev_lookup}/32 via ${ip_address_of_remote_peer_in_openvpn}
wget -4 -O /dev/null http://speedtest.tele2.net/10GB.zip
```

## Links

https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4/

https://2019.www.torproject.org/docs/tor-manual.html

http://spys.me/proxy.txt

## License

Published by CC0 1.0 license. See here: https://creativecommons.org/publicdomain/zero/1.0/

## Abuse responsibility

This is proof-of-concept anonimizer for containerized apps. The author is not responsible
for the actions of any those who use the original or modified code present here.
