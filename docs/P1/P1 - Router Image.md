---
tags: [badass, p1, docker, frr, router]
---

# P1 — Router Image (`router_mlakhdar:p1`)

← [[P1 - Overview]] · See also [[P1 - FRR Configuration Files]], [[FRRouting]]

## The Dockerfile

```dockerfile
FROM alpine:3.23

RUN apk add --no-cache \
    bash \
    frr \
    iproute2 \
    iputils \
    tcpdump \
    bridge-utils

COPY daemons /etc/frr/daemons
COPY start-router.sh /usr/local/bin/start-router
COPY frr.conf vtysh.conf /etc/frr/

RUN chmod +x /usr/local/bin/start-router \
    && mkdir -p /run/frr \
    && chown -R frr:frr /etc/frr /run/frr \
    && chmod 640 /etc/frr/frr.conf

CMD ["/usr/local/bin/start-router"]
```

### Packages

| Package | Why it's here |
|---|---|
| `bash` | `start-router.sh` uses bash (`source`, `$(...)`, interactive `-i`) |
| `frr` | **FRRouting**: the routing suite (zebra, bgpd, ospfd, isisd, vtysh…). Version 10 on Alpine 3.23 |
| `iproute2` | Full `ip` (needed for `ip link add ... type vxlan`, `type bridge`) and `bridge` (`bridge fdb`, `bridge link`) |
| `iputils` | Full `ping` (e.g. `ping -I 1.1.1.2 1.1.1.1` to test from a loopback) |
| `tcpdump` | Packet capture inside the router |
| `bridge-utils` | `brctl` (legacy bridge tool; `ip`/`bridge` do the same) |

### The `COPY` + permissions block

- `daemons` → tells FRR which daemons to launch. See [[P1 - FRR Configuration Files]].
- `frr.conf`, `vtysh.conf` → the base config.
- FRR daemons **run as user `frr`**, not root. So:
  - `/etc/frr` must be owned by `frr` (otherwise `write memory` fails with permission denied),
  - `/run/frr` must exist and be owned by `frr` (daemons put their PID files and the **vtysh sockets** there; without it, `vtysh` can't talk to the daemons),
  - `frr.conf` is `640`: readable by the group, not world-readable (it can hold passwords in real life).

## `start-router.sh`

```bash
#!/bin/bash
source /usr/lib/frr/frrcommon.sh
/usr/lib/frr/watchfrr -d $(daemon_list)
exec /bin/bash -i
```

| Line | Meaning |
|---|---|
| `source /usr/lib/frr/frrcommon.sh` | Loads FRR's own helper functions. They read `/etc/frr/daemons` |
| `daemon_list` | Prints the enabled daemons **plus the mandatory ones** (`zebra`, `mgmtd`, `staticd`) |
| `watchfrr -d ...` | `watchfrr` starts each daemon and **watches** them: if one crashes it restarts it. `-d` = run in the background (daemonize) |
| `exec /bin/bash -i` | Replace the script with an interactive bash. It becomes PID 1 → keeps the container alive and gives GNS3 a usable console |

> [!question] Why not use the usual `/usr/lib/frr/frrinit.sh start`?
> In a container there's no init system (no OpenRC/systemd). Calling `watchfrr` directly
> is the lightest way to start the daemons with supervision, then hand over to a shell.

## What runs after boot

```text
PID 1  bash -i
       watchfrr
       ├── zebra     kernel interface: pushes routes into Linux, reads interfaces / FDB
       ├── mgmtd     FRR management daemon (config backend, FRR ≥ 9)
       ├── staticd   static routes
       ├── bgpd      BGP (P3)
       ├── ospfd     OSPF (P3)
       └── isisd     IS-IS (required by the subject, not configured)
```

Check with `ps` and `vtysh -c "show daemons"`.

## What `zebra` does (important for P3)

zebra is the bridge between FRR and the Linux kernel:
- protocols (ospfd, bgpd) give their best routes to zebra → zebra installs them in the kernel routing table (`ip route`),
- zebra watches the kernel: interfaces, addresses, **VXLAN devices, bridge MAC tables**. This is how bgpd learns that a VNI exists and that a new MAC appeared on `br0` → it generates EVPN routes. See [[P3 - EVPN Route Types]].
