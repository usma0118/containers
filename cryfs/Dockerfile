FROM alpine:3.9.6 as build

# Install CryFS
ENV CRYFS_VERSION="0.11.3"

RUN apk --no-cache --no-progress upgrade && \    
    apk add --no-cache bash curl fuse libgomp libstdc++ openssl tini tzdata shadow su-exec && \
    apk add --no-cache --virtual .build-deps cmake curl-dev fuse-dev g++ gcc git make openssl-dev py3-pip python3 && \
RUN addgroup -S cryfs && \
    adduser -S -D -H -h /tmp -s /sbin/nologin -G cryfs -g 'CryFS User' cryfsuser && \
    mkdir -p /usr/src/ && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    python -m pip install conan versioneer && \
    git clone -b $CRYFS_VERSION https://github.com/cryfs/cryfs.git /usr/src/cryfs && \
    mkdir /usr/src/cryfs/cmake && \
    cd /usr/src/cryfs/cmake && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    python -m pip uninstall -y conan versioneer && \
    rm /usr/bin/python && \
    apk del .build-deps && \
    cd / && \
    rm /usr/src/ -rf && \
	echo user_allow_other >> /etc/fuse.conf


# Setup Environment
ENV CRYFS_FRONTEND="noninteractive" \
    CRYFS_OPTIONS="--create-missing-basedir --create-missing-mountpoint" \
    MOUNT_OPTIONS="allow_other,noatime,nodiratime" \
    USERID="1000" \
    GROUPID="1000"

VOLUME [ "/encrypted", "/decrypted" ]

COPY run.sh /usr/bin/run.sh

CMD [ "/sbin/tini", "--", "/usr/bin/run.sh" ]
