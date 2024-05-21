FROM ubuntu:23.10
RUN apt update && \
    apt install cryfs fuse tini tree -y
RUN useradd -s /usr/sbin/nologin -m secretfs && \
    passwd -d secretfs &&\
    echo 'nonroot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers &&\
    echo user_allow_other >> /etc/fuse.conf
# RUN addgroup -S secrefs && \
#     adduser -S -D -H -h /tmp -s /sbin/nologin -G secrefs -g 'SecureFS User' secrefs && \
#     echo user_allow_other >> /etc/fuse.conf

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /app
# COPY --from=build /usr/src/cryfs/cmake /app

# Setup Environment
ENV CRYFS_FRONTEND="noninteractive" \
    CRYFS_OPTIONS="--create-missing-basedir --create-missing-mountpoint" \
    #CRYFS_LOCAL_STATE_DIR=
    MOUNT_OPTIONS="allow_other,noatime" \
    UID="1000" \
    GID="1000"
VOLUME [ "/encrypted", "/decrypted" ]
USER secretfs
ADD ../run.sh /app/run.sh
ENTRYPOINT ["/usr/bin/tini","-s","-g","-w", "--"]
CMD ["/app/run.sh"]

LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/cryfs"
