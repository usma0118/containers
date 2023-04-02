FROM alpine:3.9.6

# Set the maintainer label
LABEL maintainer=usma0118


# Install dependencies and remove cache
RUN apk add --no-cache libc6-compat curl fuse libgomp libstdc++ openssl tini tzdata shadow tini bash && \
    sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf && \
    rm -rf /var/cache/apk/*

# Create a non-root user and group for running the container
RUN addgroup -S secureFS \
    && adduser -u 1001 securefs -S -D -H -s /sbin/nologin -G secureFS -g 'secureFS User'
    # && usermod -aG fuse secureFS

# Set environment variables
ENV CRYFS_FRONTEND="noninteractive" \
    CRYFS_OPTIONS="--create-missing-basedir --create-missing-mountpoint" \
    MOUNT_OPTIONS="allow_other,noatime,nodiratime" \
    CRYFS_NO_UPDATE_CHECK="true"

# Copy the run script to the container and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

VOLUME [ "/encrypted", "/decrypted" ]

#USER secureFS

# Set the entrypoint and default command
#ENTRYPOINT ["/sbin/tini", "-v", "--"]
CMD [ "sh" ]
#CMD ["/usr/local/bin/run.sh"]
