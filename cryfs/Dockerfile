FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get --no-install-recommends install -y build-essential
RUN apt-get --no-install-recommends install cryfs fuse tini -y &&\
    useradd -s /usr/sbin/nologin -m secretfs && passwd -d secretfs &&\
    echo 'nonroot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers &&\
    echo user_allow_other >> /etc/fuse.conf &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /app
# Setup Environment
ENV CRYFS_FRONTEND="noninteractive" \
    CRYFS_OPTIONS="--create-missing-basedir --create-missing-mountpoint" \
    MOUNT_OPTIONS="allow_other,noatime,nodiratime" \
    USERID="1000" \
    GROUPID="1000"
ENV TINI_SUBREAPER=""
VOLUME [ "/encrypted", "/decrypted" ]

COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh
# Set the entrypoint and default command
USER nobody:nobody
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/usr/bin/run.sh"]

# Set the maintainer label
LABEL maintainer=usma0118
LABEL org.opencontainers.image.description="Docker container for cryfs"
LABEL org.opencontainers.image.url="https://github.com/usma0118/containers/cryfs"
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/cryfs"
LABEL org.opencontainers.image.title="cryfs"
