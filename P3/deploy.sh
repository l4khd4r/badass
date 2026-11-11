#!/bin/sh
# =============================================================================
# P3 - copy each node's script into its GNS3 container and run it.
# Usage:
#   ./deploy.sh routers      routers only (OSPF + BGP EVPN + VXLAN)
#   ./deploy.sh hosts-noip   hosts: port up, no IP  -> EVPN type 2 routes appear
#   ./deploy.sh hosts        hosts with 20.1.1.x/24 -> ping between hosts
#   ./deploy.sh              everything (routers, then hosts with IPs)
# =============================================================================
WHAT=${1:-all}
DIR=$(dirname "$0")/scripts

ROUTERS="router-mlakhdar-1 router-mlakhdar-2 router-mlakhdar-3 router-mlakhdar-4"
HOSTS="host-mlakhdar-1 host-mlakhdar-2 host-mlakhdar-3"

case "$WHAT" in
    routers)    NODES=$ROUTERS ;;
    hosts)      NODES=$HOSTS ;;
    hosts-noip) NODES=$HOSTS; ARG=noip ;;
    all)        NODES="$ROUTERS $HOSTS" ;;
    *) echo "usage: $0 [routers|hosts|hosts-noip|all]"; exit 1 ;;
esac

for node in $NODES; do
    # GNS3 names containers "GNS3.<node-name>.<project-id>"
    c=$(docker ps --format '{{.Names}}' | grep "^GNS3\.$node\." | head -1)
    if [ -z "$c" ]; then
        echo "$node: not running, skipped"
        continue
    fi

    # Wait until GNS3 has plugged in the cables (max 20 s)
    for i in $(seq 1 20); do
        docker exec "$c" ip link show eth0 >/dev/null 2>&1 && break
        sleep 1
    done
    if ! docker exec "$c" ip link show eth0 >/dev/null 2>&1; then
        echo "$node: no eth0 - is the project open and started in GNS3? skipped"
        continue
    fi

    echo "== $node"
    docker cp "$DIR/$node.sh" "$c:/tmp/$node.sh" >/dev/null
    docker exec "$c" sh "/tmp/$node.sh" $ARG
done
