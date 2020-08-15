FROM centos:8

ARG TMP_PACKAGES="gcc make python3-devel"
RUN yum install --assumeyes                                 \
        ca-certificates                                     \
        curl                                                \
        iptables                                            \
        net-tools                                           \
        python3                                             \
        python3-pip                                         \
        wget                                             && \
    pip3 install --no-cache --no-cache-dir                  \
        setuptools                                          \
        wheel                                            && \
    yum install --assumeyes                                 \
        ${TMP_PACKAGES}                                  && \
    pip3 install --no-cache --no-cache-dir                  \
        pycrypt==0.7.2                                      \
        pycryptodome==3.9.8                                 \
        pyroute2==0.5.12                                    \
        python-iptables==1.0.0                              \
        requests==2.24.0                                 && \
    yum remove --assumeyes                                  \
        ${TMP_PACKAGES}                                  && \
    yum autoremove --assumeyes                           && \
    yum clean all --assumeyes                            && \
    rm -rf /var/cache/yum

COPY ./docker /

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
