FROM ubuntu:focal

ARG DEBIAN_FRONTEND="noninteractive"
ARG TMP_PACKAGES="gcc make python3-dev"
RUN apt-get update                                       && \
    apt-get install --no-install-recommends -y              \
        ca-certificates                                     \
        curl                                                \
        iproute2                                            \
        iptables                                            \
        iputils-ping                                        \
        net-tools                                           \
        python3                                             \
        python3-pip                                         \
        wget                                             && \
    pip3 install --no-cache --no-cache-dir                  \
        setuptools                                          \
        wheel                                            && \
    apt-get install --no-install-recommends -y              \
        ${TMP_PACKAGES}                                  && \
    pip3 install --no-cache --no-cache-dir                  \
        pycrypt==0.7.2                                      \
        pycryptodome==3.9.8                                 \
        pyroute2==0.5.12                                    \
        python-iptables==1.0.0                              \
        requests==2.24.0                                 && \
    apt-get purge -y                                        \
        ${TMP_PACKAGES}                                  && \
    apt-get autoremove -y                                && \
    apt-get clean -y                                     && \
    apt-get autoclean -y                                 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./docker /

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
