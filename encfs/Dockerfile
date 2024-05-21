FROM alpine:3.18.4 as build
RUN apk add --no-cache git
WORKDIR /nova
RUN git clone --depth 1 https://github.com/novafacile/novagallery .\
&& mv src/nova-config/site.example.php src/nova-config/site.php

FROM alpine:3.18.4

# Set the maintainer label
LABEL maintainer=usma0118
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/encfs"

# Install dependencies and remove cache
RUN apk add --no-cache libc6-compat fuse3 encfs s6 bash apache2 php82-apache2 && \
rm -rf /var/cache/apk/* && \
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# Create a non-root user and group for running the container
RUN addgroup -S secureFS \
    && adduser -u 1001 securefs -S -D -H -s /sbin/nologin -G secureFS -g 'secureFS User'

# Set the overlay as a version.
ENV S6_OVERLAY_VERSION="3.1.6.2" \
 S6_BEHAVIOUR_IF_STAGE2_FAILS=2
#S6_READ_ONLY_ROOT=1
#S6_VERBOSITY=5

# Install s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
# Download s6-overlay based on system architecture
RUN echo $(apk --print-arch) && apk add --no-cache curl && \
    case $(apk --print-arch) in \
    x86_64) ARCH=x86_64;; \
    aarch64) ARCH=aarch64;; \
      *) echo "Unsupported architecture"; exit 1;; \
    esac && \
    curl -L -o /tmp/s6-overlay-${ARCH}.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-${ARCH}.tar.gz\
    && rm /tmp/*

WORKDIR /etc/s6-overlay/s6-rc.d
COPY --chmod=755 s6-overlay/s6-rc.d/ .

WORKDIR /run
RUN ln -s /run /var/run

WORKDIR /var/www/localhost/htdocs
COPY --from=build /nova/src .
EXPOSE 80

# Set environment variables
ENV MOUNT_OPTIONS="allow_other,noatime"

WORKDIR /app

# Copy the run script to the container and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh
USER secureFS
#HEALTHCHECK CMD wget -q --no-cache --spider localhost
# Set the entrypoint and default command
ENTRYPOINT ["/init"]
#CMD ["/app/run.sh"]
