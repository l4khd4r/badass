#!/bin/sh

# P2 - copy each's script into its' GNS3 container and run it
# Usage: sh deploy.sh static | multicast

MODE=${1:-static}
DIR=$(dirname "$0")/scripts


for node in router-mlakhdar-1 router-mlakhdar-2 host-mlakhdar-1 host-mlakhdar-2; do 
    echo "Deploying $node"
    c=$(docker ps --format '{{.Names}}' | grep "^GNS3\.$node\." | head -1)
    if [ -z "$c" ]; then
        echo "Error: container for $node not running, skipped"
        continue 
    fi

    echo "== $node ($MODE) =="
    docker cp "$DIR/$node.sh" "$c:/tmp/$node.sh" # copy script in
    docker exec -it "$c" sh "/tmp/$node.sh" "$MODE" # run the script in
done