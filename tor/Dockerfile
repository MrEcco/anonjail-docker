FROM alpine:3.12.0

RUN apk add --no-cache                                      \
        bash                                                \
        py3-pip                                             \
        python3                                             \
        tor                                              && \
    pip3 install --no-cache --no-cache-dir                  \
        nyx==2.1.0 stem==1.8.0                           && \
    mkdir -p /var/lib/tor /var/run/tor /etc/tor          && \
    chown tor /var/lib/tor /var/run/tor                  && \
    chmod 700 /var/lib/tor /var/run/tor                  && \
    rm -rf /var/lib/tor/* /var/run/tor/* /etc/tor/* || true

COPY ./tor/docker /

RUN chown tor /etc/tor/torrc

ENV TOR_CONTROL_PORT="/var/run/tor/control"

USER "tor"

EXPOSE 9050

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["-f", "/etc/tor/torrc"]

# # /usr/local/bin/entrypoint.sh -f /etc/tor/torrc