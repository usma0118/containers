FROM alpine:3.18.4 as build

# Install CryFS
ENV CRYFS_VERSION="0.11.4"

RUN apk --no-cache --no-progress upgrade && \
    apk add --no-cache fuse tini && \
    apk add --no-cache git g++ cmake make pkgconfig python3 && \
    apk add --no-cache bash curl libgomp libstdc++ openssl tini tzdata shadow su-exec && \
    apk add --no-cache --virtual .build-deps cmake curl-dev fuse-dev g++ gcc git make openssl-dev py3-pip python3 && \
    mkdir -p /usr/src/
    # ln -s /usr/bin/python3 /usr/bin/python && \
RUN  python -m pip install --no-cache-dir conan==1.60.1 versioneer && \
    git clone --depth 1 -b $CRYFS_VERSION https://github.com/cryfs/cryfs.git /usr/src/cryfs && \
    mkdir /usr/src/cryfs/cmake && \
    cd /usr/src/cryfs/cmake && \
    # conan profile detect && \
    cmake .. && \
    make -j$(nproc) && \
    make install
RUN    python -m pip uninstall -y conan versioneer && \
    rm /usr/bin/python && \
    apk del .build-deps && \
    cd / && \
    rm /usr/src/ -rf
RUN addgroup -S secrefs && \
    adduser -S -D -H -h /tmp -s /sbin/nologin -G secrefs -g 'SecureFS User' secrefs && \
    echo user_allow_other >> /etc/fuse.conf


# Setup Environment
ENV CRYFS_FRONTEND="noninteractive" \
    CRYFS_OPTIONS="--create-missing-basedir --create-missing-mountpoint" \
    MOUNT_OPTIONS="allow_other,noatime,nodiratime" \
    USERID="1000" \
    GROUPID="1000"
ENV TINI_SUBREAPER=""
VOLUME [ "/encrypted", "/decrypted" ]

COPY run.sh /usr/bin/run.sh

USER secrefs
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/usr/local/bin/run.sh"]

LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/cryfs"
