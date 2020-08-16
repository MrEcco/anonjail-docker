FROM alpine:3.12.0

RUN apk add --no-cache                                      \
        bash                                                \
        gcc                                                 \
        git                                                 \
        iptables                                            \
        musl-dev                                            \
        proxychains-ng                                      \
        py3-pip                                             \
        python3                                             \
        python3-dev                                      && \
    pip3 install --no-cache --no-cache-dir                  \
        python-iptables==1.0.0 pyroute2==0.5.12          && \
    pip3 install --no-cache --no-cache-dir                  \
        --force-reinstall                                   \
        git+https://github.com/facebookexperimental/doh-proxy.git && \
    pip3 install --no-cache --no-cache-dir                  \
        --force-reinstall                                   \
        git+https://github.com/URenko/aioh2.git          && \
    apk del                                                 \
        gcc                                                 \
        git                                                 \
        musl-dev                                            \
        python3-dev                                      && \
    rm /etc/proxychains/* || true

COPY ./doh/docker /

EXPOSE 53/UDP

### Google (default)
ENV DNS_OVER_HTTPS_IP="8.8.8.8"
ENV DNS_OVER_HTTPS_DOMAIN="dns.google"

### Cloudflare
# ENV DNS_OVER_HTTPS_IP="1.1.1.1"
# ENV DNS_OVER_HTTPS_DOMAIN="cloudflare-dns.com"

### Use your own!
# ENV DNS_OVER_HTTPS_IP=$(echo Yor numeric IP!)
# ENV DNS_OVER_HTTPS_DOMAIN=$(echo | openssl s_client -no_ssl3 -tlsextdebug -crlf -4 -connect ${DNS_OVER_HTTPS_IP}:443 2>&1 | grep depth=0 | sed "s/^.*CN = //g")

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["-f", "/etc/tor/torrc"]

# # /usr/local/bin/entrypoint.sh -f /etc/tor/torrc