FROM alpine:3.9.6

# Set the maintainer label
LABEL maintainer=usma0118


# Install dependencies and remove cache
RUN apk add --no-cache libc6-compat encfs tini bash && \
    sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf && \
    rm -rf /var/cache/apk/*

# Create a non-root user and group for running the container
RUN addgroup -S secureFS \
    && adduser -u 1001 securefs -S -D -H -s /sbin/nologin -G secureFS -g 'secureFS User'
    # && usermod -aG fuse secureFS

# Set environment variables
ENV MOUNT_OPTIONS="allow_other,noatime"

# Copy the run script to the container and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

USER secureFS

# Set the entrypoint and default command
ENTRYPOINT ["/sbin/tini", "-v", "--"]
CMD ["/usr/local/bin/run.sh"]
