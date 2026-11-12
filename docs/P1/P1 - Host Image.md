---
tags: [badass, p1, docker, host]
---

# P1 — Host Image (`host_mlakhdar:p1`)

← [[P1 - Overview]]

## The Dockerfile

```dockerfile
FROM alpine:3.23

RUN apk add --no-cache \
    iproute2 \
    iputils \
    tcpdump \
    net-tools

CMD ["/bin/sh"]
```

| Line | Why |
|---|---|
| `FROM alpine:3.23` | Minimal Linux whose base tools come from **BusyBox** |
| `iproute2` | The full `ip` command (`ip addr`, `ip link`, `ip route`, `ip neigh`). BusyBox has a reduced `ip`; iproute2 gives every option |
| `iputils` | Full `ping` (with `-I`, flood options, etc.) |
| `tcpdump` | Capture packets directly in the node to see ARP, ICMP… |
| `net-tools` | Legacy tools: `ifconfig`, `netstat`, `arp`, `route` |
| `CMD ["/bin/sh"]` | The container's main process is a shell. GNS3 attaches its console to it. As long as the shell lives, the container lives |

## Its role in each part

| Part | Interface | Address | Notes |
|---|---|---|---|
| P1 | eth0 | none | just boots |
| P2 | eth0 | 30.1.1.1/24 or 30.1.1.2/24 | [[P2 - Overview]] |
| P3 | eth0 or eth1 | 20.1.1.1–3/24 | [[P3 - Overview]] |

> [!info] The host never knows about VXLAN or BGP
> From the host's point of view, the other hosts are simply on the same Ethernet LAN.
> All the magic happens in the routers. This is exactly what happens with a real server
> in a data center. See [[Underlay vs Overlay]].

## Why no default gateway?

All hosts in P2 (30.1.1.0/24) and P3 (20.1.1.0/24) are in **the same subnet**. When a host wants to reach an address in its own subnet, it doesn't need a router: it [[ARP|ARPs]] for the MAC and sends the frame directly. The overlay makes this work across routers.
