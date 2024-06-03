FROM alpine:3.19.1

# Set the maintainer label
LABEL maintainer=usma0118
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/encfs"
LABEL org.opencontainers.image.description="Docker container for encfs"
LABEL org.opencontainers.image.url="https://github.com/usma0118/containers/encfs"
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/encfs"
# Install dependencies and remove cache
RUN apk add --no-cache libc6-compat=1.2.2-r9 fuse3=3.16.2-r0 encfs=1.9.5-r24 tini=0.19.0-r3 bash=5.2.26-r0 && \
rm -rf /var/cache/apk/* && \
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# Create a non-root user and group for running the container
RUN addgroup --gid 1001 -S secureFS \
    && adduser -u 1001 securefs -S -D -H -s /sbin/nologin -G secureFS -g 'secureFS User'

    # Set environment variables
ENV MOUNT_OPTIONS="allow_other,noatime"
VOLUME /encrypted
VOLUME /decrypted
WORKDIR /app

# Copy the run script to the container and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh
USER nobody:nobody
#HEALTHCHECK CMD wget -q --no-cache --spider localhost
# Set the entrypoint and default command
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/app/run.sh"]
