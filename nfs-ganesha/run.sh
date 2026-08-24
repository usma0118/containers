#!/bin/sh

set -eu

exec /usr/bin/ganesha.nfsd \
    -F \
    -f /etc/ganesha/ganesha.conf
