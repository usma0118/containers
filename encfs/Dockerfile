FROM alpine:3.19.1 as build
RUN apk add --no-cache git
WORKDIR /nova
RUN git clone --depth 1 https://github.com/novafacile/novagallery .\
&& mv src/nova-config/site.example.php src/nova-config/site.php

FROM alpine:3.19.1

# Set the maintainer label
LABEL maintainer=usma0118
LABEL org.opencontainers.image.source="https://github.com/usma0118/containers/encfs"

# Install dependencies and remove cache
RUN apk add --no-cache libc6-compat fuse3 encfs tini bash apache2 php82-apache2 && \
rm -rf /var/cache/apk/* && \
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# Create a non-root user and group for running the container
RUN addgroup -S secureFS \
    && adduser -u 1001 securefs -S -D -H -s /sbin/nologin -G secureFS -g 'secureFS User'

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
HEALTHCHECK CMD wget -q --no-cache --spider localhost
# Set the entrypoint and default command
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/app/run.sh"]
