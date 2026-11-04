#!/bin/bash
set -e
cd "$(dirname "$0")"   # run relative to P1/ wherever you call it from

docker build --file ./host/Dockerfile   --tag host_mlakhdar:p1   ./host    
docker build --file ./router/Dockerfile --tag router_mlakhdar:p1 ./router 