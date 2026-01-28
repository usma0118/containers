FROM alpine:3.23.3

# Set the maintainer label
LABEL maintainer=usma0118
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/encfs"
LABEL org.opencontainers.image.description="Docker container for encfs"
LABEL org.opencontainers.image.url="https://github.com/usma0118/containers/encfs"
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/encfs"
# Install dependencies and remove cache
RUN apk update --no-cache && apk upgrade --no-cache && \
    apk add --no-cache encfs tini && \
    rm -rf /var/cache/apk/* && \
    sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
# Set environment variables
ENV MOUNT_OPTIONS="allow_other,noatime"
VOLUME /encrypted
VOLUME /decrypted
WORKDIR /decrypted

# Copy the run script to the container and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh
USER nobody:nobody
#HEALTHCHECK CMD wget -q --no-cache --spider localhost
# Set the entrypoint and default command
ENTRYPOINT ["/sbin/tini", "-g","-w", "--"]
CMD ["/app/run.sh"]
