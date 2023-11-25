FROM alpine:3.18.4

# Set the maintainer label
LABEL maintainer=usma0118
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/encfs"

# Install dependencies and remove cache
RUN apk add --no-cache libc6-compat encfs tini bash && \
rm -rf /var/cache/apk/* && \
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# Create a non-root user and group for running the container
RUN addgroup -S secureFS \
    && adduser -u 1001 securefs -S -D -H -s /sbin/nologin -G secureFS -g 'secureFS User'

# Set environment variables
ENV MOUNT_OPTIONS="allow_other,noatime"

WORKDIR /app
# Copy the run script to the container and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

USER secureFS

# Set the entrypoint and default command
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/app/run.sh"]
