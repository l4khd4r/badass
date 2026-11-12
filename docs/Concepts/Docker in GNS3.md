---
tags: [concept, tooling, docker, gns3]
aliases: [GNS3, Docker]
---

# Docker in GNS3

← [[Concept Map]] · Workflow: [[01 Lab Workflow]]

## Docker vocabulary

| Term | Meaning |
|---|---|
| **Image** | a frozen filesystem + start command (`host_mlakhdar:p1`) |
| **Container** | a running instance of an image, with its own network namespace, processes, filesystem layer |
| **Dockerfile** | recipe to build an image |
| **Build context** | the directory sent to `docker build`; `COPY` can only see files inside it |
| **Tag** | `name:version` label of an image |

A container is **not a VM**: it shares the host's kernel. That's why VXLAN, bridges, routes inside a container are really Linux kernel features, isolated in its **network namespace**.

## What GNS3 adds

- Each node = one container named `GNS3.<node-name>.<project-id>`.
- GNS3 creates the interfaces `eth0`, `eth1`, … and connects them to other nodes according to the drawn links (via its `ubridge` helper).
- The container gets network-admin capabilities, so `ip link add … type vxlan` works inside.
- The console is attached to the container's main process (the shell) → `CMD ["/bin/sh"]` / `exec bash -i`.
- Right-click a link → **Start capture** → Wireshark on that virtual cable.

## Consequences for the project

- Images must be built **before** importing a project: `.gns3project` doesn't contain them.
- Node names can't contain `_` in GNS3 3.x → `router-mlakhdar-1`.
- Restart a node → interfaces recreated → **re-run `deploy.sh`**.
- Config is pushed with `docker cp` + `docker exec` from the host machine.
