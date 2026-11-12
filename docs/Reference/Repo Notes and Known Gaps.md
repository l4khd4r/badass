---
tags: [reference, todo]
---

# Repo notes and known gaps

← [[00 Home]]

Small inconsistencies found while writing this vault (2026-11-12). None of them break the lab, but an evaluator reading the files might notice them.

## Documentation vs code

- [ ] **`P1/host/README.md` lists `dig` and `ethtool`**, but `P1/host/Dockerfile` only installs `iproute2 iputils tcpdump net-tools`. Either add `bind-tools ethtool` to the Dockerfile or remove those lines from the README.
- [ ] **`P1/host/README.md` and `P1/router/README.md` build commands** use `badass-host:1.0` / `badass-router:1.0` with the repo root as the build context (`-f P1/router/Dockerfile .`). The real script uses `host_mlakhdar:p1` / `router_mlakhdar:p1` with `./host` and `./router` as contexts. The router command from the README would **fail**, because `COPY daemons …` looks for `./daemons` at the repo root. Align them with `image_builder.sh`.
- [ ] `P1/router/README.md` mentions "the startup script launches FRR" — accurate, but could say it uses `watchfrr` (see [[P1 - Router Image]]).

## Scripts

- [ ] **`P2/deploy.sh` uses `docker exec -it`**. `-t` needs a terminal: running the script from a non-interactive context (pipe, CI, some IDE runners) fails with *"the input device is not a TTY"*. P3's `deploy.sh` already drops `-it`; P2 could do the same.
- [ ] `P2/deploy.sh` has no wait for `eth0` (P3's does). If run immediately after ▶ Start, the first node can be configured before GNS3 plugs its cables.
- [ ] `P2/scripts/host-mlakhdar-2.sh`: `ip addr flush dev eth0` has no `2>/dev/null` while host 1 does — harmless, just inconsistent.

## Design notes worth being able to explain

- Single route reflector = single point of failure for both control plane and (here) underlay. Fine for the lab. → [[Route Reflector]]
- Type 2 routes are **MAC-only** (no SVI / no ARP suppression configured). → [[P3 - EVPN Route Types]]
- IS-IS daemon is enabled but unused (subject requirement). → [[P1 - FRR Configuration Files]]
