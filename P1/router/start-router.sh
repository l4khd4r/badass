#!/bin/sh
set -eu

mkdir -p /run/frr
chown frr:frr /run/frr

/usr/lib/frr/watchfrr \
    -d \
    -F traditional \
    zebra bgpd ospfd isisd staticd

exec /bin/bash -i