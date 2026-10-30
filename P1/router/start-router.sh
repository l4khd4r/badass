#!/bin/sh
set -eu

/bin/bash /usr/lib/frr/frrinit.sh start

exec /bin/sh
