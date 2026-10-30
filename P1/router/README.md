# BADASS P1 — Router Image

## Purpose
Reusable Linux router for the BADASS GNS3 lab.

## Components
- Alpine Linux and BusyBox
- FRRouting (FRR)
- BGP daemon: bgpd
- OSPF daemon: ospfd
- IS-IS daemon: isisd
- Zebra routing manager
- iproute2, ping, and tcpdump

## Build
From the repository root:

    docker build -t badass-router:1.0 -f P1/router/Dockerfile .

## Network configuration
The image does not configure static IP addresses.
Interfaces and routing protocol parameters will be configured
for individual devices in the lab.

## Startup
The startup script launches FRR and provides an interactive shell.
