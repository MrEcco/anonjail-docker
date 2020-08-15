FROM alpine:3.12.0

RUN apk add --no-cache                                      \
        bash                                                \
        gcc                                                 \
        musl-dev                                            \
        proxychains-ng                                      \
        py3-pip                                             \
        python3                                             \
        python3-dev                                      && \
    pip3 install --no-cache --no-cache-dir                  \
        pycrypt==0.7.2                                      \
        pycryptodome==3.9.8                                 \
        pyroute2==0.5.12                                    \
        python-iptables==1.0.0                              \
        requests==2.24.0                                 && \
    apk del                                                 \
        gcc                                                 \
        musl-dev                                            \
        python3-dev

COPY ./docker /

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
