#!/bin/bash
set -e

docker build \
    --file ./host/host_mlakhdar.Dockerfile \
    --tag host_mlakhdar:p1 \
    ./host

docker build \
    --file ./router/router_mlakhdar.Dockerfile \
    --tag router_mlakhdar:p1 \
    ./router