FROM alpine:3.18.4 as build
RUN apk add --no-cache git
WORKDIR /nova
RUN git clone --depth 1 https://github.com/novafacile/novagallery .\
&& mv src/nova-config/site.example.php src/nova-config/site.php

FROM ubuntu:23.10
#alpine:3.18.4

# Set the maintainer label
LABEL maintainer=usma0118
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/encfs"

RUN apt update
RUN apt install --no-install-recommends fuse encfs s6 apache2 libapache2-mod-php xz-utils ca-certificates wget -y && \
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

RUN apt-get update && apt-get install --assume-yes --no-install-recommends \
    libmemcached-dev libzip-dev

# Set the overlay as a version.
ENV S6_OVERLAY_VERSION="3.1.6.2"
#\
# S6_BEHAVIOUR_IF_STAGE2_FAILS=2
#S6_VERBOSITY=5

# Install s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

ADD https://github.com/DirectoryLister/DirectoryLister/releases/download/3.12.3/DirectoryLister-3.12.3.tar.gz /tmp
RUN tar -C /var/www/html  -xpf /tmp/DirectoryLister-3.12.3.tar.gz

# Download s6-overlay based on system architecture
RUN dpkgArch="$(dpkg --print-architecture)" && echo $dpkgArch && \
    case "${dpkgArch##*-}" in \
        amd64) ARCH='x86_64'; ;; \
        armhf) ARCH='arm'; ;; \
        arm64) ARCH='aarch64'; ;; \
        *) echo "Unsupported architecture"; exit 1 ;; \
    esac && \
    wget -q -O "/tmp/s6-overlay-${ARCH}.tar.xz" "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz" && \
    tar -C / -Jxpf "/tmp/s6-overlay-${ARCH}.tar.xz" && \
    apt-get remove -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /etc/s6-overlay/s6-rc.d
COPY --chmod=755 s6-overlay/s6-rc.d/ .

# Ensure that /run is created and set correct permissions
#RUN mkdir -p /run && chmod 1777 /run
# Create symbolic link from /run to /var/run
#RUN ln -s /run /var/run

WORKDIR /var/www/html
RUN rm index.html
#COPY --chown=www-data:www-data --from=build /nova/src .
#RUN ln -s /decrypted /var/www/html/galleries/private
RUN a2enmod rewrite

EXPOSE 80
# Create a non-root user and group for running the container
RUN addgroup --system secureFS \
    && adduser --uid 1001 --disabled-password --ingroup secureFS --gecos 'secureFS User' securefs
# Set environment variables
ENV MOUNT_OPTIONS="allow_other,noatime"

WORKDIR /app

# Copy the run script to the container and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh
#HEALTHCHECK CMD wget -q --no-cache --spider localhost
# Set the entrypoint and default command
ENTRYPOINT ["/init"]
CMD ["bash"]
