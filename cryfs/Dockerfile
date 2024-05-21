FROM alpine:3.19.1 as build

# Install CryFS
ENV CRYFS_VERSION="0.11.4"
RUN apk add --no-cache \
    bash\
    ca-certificates\
    curl\        
    fuse3 fuse-dev\
    linux-headers
    # libunwind libunwind-dev
RUN apk add --no-cache\
    --virtual .build-deps\
    musl-dev \    
    clang>=7 make cmake>=3.10 git py3-setuptools py3-pkgconfig\
    libgomp\
    libstdc++\
    procps\
    #gcc\
    g++\      
    fuse-dev\
    perl\
    python3\    
    python3-dev\
    py3-pip\
    py3-virtualenv\
    boost-dev

RUN apk update && apk add --no-cache \
bash \
build-base \
gcc \
g++ \
libc-dev \
linux-headers \
python3 \
py3-pip \
cmake \
boost-dev \
boost-build \
zlib-dev \
bzip2-dev \
zstd-dev \
icu-dev

# Set environment variables if needed
ENV CC=gcc
ENV CXX=g++
    
WORKDIR /usr/src/
RUN git clone https://github.com/cryfs/cryfs.git cryfs -q
RUN virtualenv /usr/src/cryfs/.venv
ENV VIRTUAL_ENV /usr/src/cryfs/.venv
ENV PATH $VIRTUAL_ENV:$PATH
WORKDIR /usr/src/cryfs/build
RUN . $VIRTUAL_ENV/bin/activate &&\
    echo "$(which python)" &&\
    python -m pip install\
    versioneer\
    conan==1.62.0\
    numpy &&\
    conan config set general.revisions_enabled=1 && \
    conan profile new default --detect && \
    conan profile update settings.compiler.libcxx=libstdc++11 default &&\
    cmake .. && make -j$(nproc)\
    && make install
    && python -m pip uninstall -y conan versioneer && \
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
