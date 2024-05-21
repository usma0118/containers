FROM alpine:3.18.4 as build

# Install CryFS
ENV CRYFS_VERSION="0.11.4"
RUN apk add --no-cache\
      fuse3\
      openssl\
      curl\
      bash
RUN apk add --no-cache\
    --virtual .build-deps\
    #musl-dev \
    ca-certificates\
    linux-headers fuse-dev make cmake>=3.10 git\
    py3-setuptools\
    py3-pkgconfig\
    python3\
    python3-dev\
    py3-pip\
    libgomp\
    libstdc++\
    procps\
    #clang>=7
    gcc>=7\
    g++\
    fuse-dev\
    perl\
    boost-dev\
    fmt fmt-dev\
    openmp
WORKDIR /usr/src/
RUN python3 -m pip install\
    versioneer\
    conan==1.62.0\
    numpy\
    && python3 -m pip install --upgrade pip setuptools wheel
RUN git clone https://github.com/cryfs/cryfs.git cryfs
WORKDIR /usr/src/cryfs/build
RUN cmake ..\
    && make -j$(nproc)\
    && make install
RUN python -m pip uninstall -y conan versioneer && \
    rm /usr/bin/python && \
    apk del .build-deps
# FROM alpine:3.18.4
RUN apk --no-cache --no-progress upgrade && \
    apk add --no-cache fuse tini
RUN addgroup -S secrefs && \
    adduser -S -D -H -h /tmp -s /sbin/nologin -G secrefs -g 'SecureFS User' secrefs && \
    echo user_allow_other >> /etc/fuse.conf
WORKDIR /app
# COPY --from=build /usr/src/cryfs/cmake /app

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
