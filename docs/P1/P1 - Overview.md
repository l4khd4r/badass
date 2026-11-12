---
tags: [badass, p1, docker, gns3]
---

# P1 — GNS3 configuration with Docker

← [[00 Home]] · Next: [[P2 - Overview]]

![[p1.png]]

## Goal

Build the **two reusable building blocks** of the whole project:

| Image | Tag | Built from | Used as |
|---|---|---|---|
| Host | `host_mlakhdar:p1` | `P1/host/Dockerfile` | an end machine (a "server" in the data center) |
| Router | `router_mlakhdar:p1` | `P1/router/Dockerfile` | a router / switch / VTEP running [[FRRouting]] |

The P1 topology is just **two unconnected nodes** (`host-mlakhdar-1` and `routeur-mlakhdar`): the point is to prove the images boot correctly in GNS3, not to build a network yet.

> [!important] No IP address anywhere
> The subject requires that **neither image contains an IP configuration**.
> Addresses are added later, per node, by the P2/P3 scripts. This is why the router's
> `frr.conf` is almost empty.

## Files

| File | Role | Detailed note |
|---|---|---|
| `P1/image_builder.sh` | builds both images | below |
| `P1/host/Dockerfile` | Alpine + network tools | [[P1 - Host Image]] |
| `P1/router/Dockerfile` | Alpine + FRR | [[P1 - Router Image]] |
| `P1/router/start-router.sh` | starts FRR daemons, then a shell | [[P1 - Router Image]] |
| `P1/router/daemons` | which FRR daemons are enabled | [[P1 - FRR Configuration Files]] |
| `P1/router/frr.conf` | base FRR config, no IP | [[P1 - FRR Configuration Files]] |
| `P1/router/vtysh.conf` | "integrated config" mode | [[P1 - FRR Configuration Files]] |
| `P1/P1.gns3project` | GNS3 portable export | [[01 Lab Workflow]] |

## `image_builder.sh` line by line

```bash
#!/bin/bash
set -e                     # stop at the first failing command
cd "$(dirname "$0")"       # move into P1/, wherever the script is called from

docker build --file ./host/Dockerfile   --tag host_mlakhdar:p1   ./host
docker build --file ./router/Dockerfile --tag router_mlakhdar:p1 ./router
```

- `set -e`: if the host build fails, the router build is not attempted.
- `cd "$(dirname "$0")"`: makes relative paths (`./host`, `./router`) work even if you run `./P1/image_builder.sh` from the repo root.
- The last argument of `docker build` is the **build context**: the directory whose files `COPY` can see. For the router this must be `./router`, because the Dockerfile does `COPY daemons ...`, `COPY start-router.sh ...`.

## Why Alpine?

- Tiny (a few MB) → fast to start many nodes in GNS3.
- Its userland is **BusyBox**: one binary that provides `sh`, `ls`, `ps`, a basic `ip`, `ping`, … The subject asks for busybox on the host.
- `apk add --no-cache` installs packages without keeping the index → smaller image.

## Verification

On the **router** console:

```sh
ps                               # watchfrr, zebra, mgmtd, staticd, bgpd, ospfd, isisd
vtysh -c "show daemons"
vtysh -c "show running-config"   # no IP address
ip -4 addr                       # only 127.0.0.1 on lo
```

On the **host** console:

```sh
ps          # /bin/sh
ip addr     # no inet on eth0
```

## What you should understand after P1

- [ ] What a Docker image vs container is, and what a build context is
- [ ] How GNS3 turns an image into a node with interfaces → [[Docker in GNS3]]
- [ ] What FRR is and what each daemon does → [[FRRouting]]
- [ ] Why the images carry no IP config
