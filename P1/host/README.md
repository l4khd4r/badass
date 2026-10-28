# BADASS P1 — Host Image

## Purpose
A reusable Linux host for the BADASS GNS3 network lab.

## Base image
Alpine Linux 3.23. BusyBox is included in the base image.

## Network tools
- `ip`: inspect network interfaces, addresses, and routes.
- `ping`: test connectivity.
- `tcpdump`: capture and inspect packets.
- `dig` and related tools: DNS troubleshooting.
- `ethtool`: inspect network interface properties.

## Build
From the repository root:

```sh
docker build -t badass-host:1.0 -f P1/host/Dockerfile .
