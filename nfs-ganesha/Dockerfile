FROM cgr.dev/chainguard/wolfi-base:latest

RUN apk add --no-cache \
    nfs-ganesha \
    ceph-20-libs \
    acl \
    tini

RUN mkdir -p \
        /etc/ganesha \
        /etc/ceph \
        /run/ganesha \
        /var/log/ganesha \
    && chown -R nobody:nobody \
        /etc/ganesha \
        /run/ganesha \
        /var/log/ganesha

COPY run.sh /usr/local/bin/run.sh

RUN chmod 0755 /usr/local/bin/run.sh \
    && chown nobody:nobody /usr/local/bin/run.sh

USER nobody:nobody

EXPOSE 2049/tcp

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/local/bin/run.sh"]
