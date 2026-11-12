---
tags: [badass, p2, vxlan, scripts]
---

# P2 — Script walkthrough

← [[P2 - Overview]]

## `deploy.sh`

```sh
MODE=${1:-static}                    # first argument, default "static"
DIR=$(dirname "$0")/scripts

for node in router-mlakhdar-1 router-mlakhdar-2 host-mlakhdar-1 host-mlakhdar-2; do
    c=$(docker ps --format '{{.Names}}' | grep "^GNS3\.$node\." | head -1)
    [ -z "$c" ] && { echo "not running, skipped"; continue; }
    docker cp "$DIR/$node.sh" "$c:/tmp/$node.sh"
    docker exec -it "$c" sh "/tmp/$node.sh" "$MODE"
done
```

- Routers first, then hosts.
- `${1:-static}` is shell "default value" syntax.
- `grep "^GNS3\.$node\."`: GNS3 container names are `GNS3.<node>.<uuid>`. The trailing `\.` avoids `router-mlakhdar-1` also matching `router-mlakhdar-10`.
- `MODE` is passed to every script; hosts ignore it (the host never sees the tunnel).

## Router script (`router-mlakhdar-1.sh`)

```sh
MODE=${1:-static}

# 1. Underlay
ip addr replace 10.1.1.1/24 dev eth0
ip link set eth0 up

# 2. Clean old tunnel
ip link del vxlan10 2>/dev/null

# 3. Tunnel
if [ "$MODE" = "multicast" ]; then
    ip link add vxlan10 type vxlan id 10 group 239.1.1.1 local 10.1.1.1 dstport 4789 dev eth0
else
    ip link add vxlan10 type vxlan id 10 local 10.1.1.1 remote 10.1.1.2 dstport 4789 dev eth0
fi

# 4. Bridge
ip link add br0 type bridge 2>/dev/null
ip link set eth1 master br0
ip link set vxlan10 master br0

# 5. Up
ip link set eth1 up
ip link set vxlan10 up
ip link set br0 up
```

### 1. Underlay address

- `ip addr replace` = add, or update if it already exists → no "File exists" error on a second run.
- Adding 10.1.1.1/24 automatically creates a **connected route** `10.1.1.0/24 dev eth0`. That's all the routing P2 needs: both VTEPs are on the same subnet.

### 2. Delete the old tunnel

You can't change `remote` ↔ `group` on an existing VXLAN device, so the script deletes and recreates it. `2>/dev/null` hides the error the first time (nothing to delete).

### 3. The VXLAN device — every option

| Option | Meaning |
|---|---|
| `vxlan10` | interface name (free choice; matches the VNI for readability) |
| `type vxlan` | create a VXLAN tunnel interface — see [[VXLAN]] |
| `id 10` | the [[VNI]]: written in the VXLAN header of every packet. Both ends must agree |
| `local 10.1.1.1` | **outer source IP** of encapsulated packets (this [[VTEP]]) |
| `remote 10.1.1.2` | static mode: **outer destination** for BUM traffic (and default destination) |
| `group 239.1.1.1` | multicast mode: BUM traffic goes to this group; the kernel joins it (IGMP) on `dev` |
| `dstport 4789` | IANA VXLAN port. ⚠️ Linux's default is **8472** (pre-standard) — forgetting it breaks interop and Wireshark's auto-decode |
| `dev eth0` | underlay interface to send through (required for multicast: which interface joins the group) |

`239.0.0.0/8` is the "administratively scoped" multicast range: private, like 10.0.0.0/8 for unicast.

### 4. The bridge

`br0` is a software switch ([[Linux Bridge]]). Its two ports:
- `eth1` → towards the host,
- `vxlan10` → towards the other VTEP(s).

Putting `eth1` in a bridge makes it a pure **L2 port**: it has no IP. A frame arriving on `eth1` for an unknown MAC is flooded to `vxlan10` → encapsulated → sent across.

### 5. Bring everything up

Interfaces are created **down**. Order doesn't matter much; all three must be up.

## Host script (`host-mlakhdar-1.sh`)

```sh
ip addr flush dev eth0 2>/dev/null   # forget old addresses (idempotent)
ip addr add 30.1.1.1/24 dev eth0     # overlay address
ip link set eth0 up
ip addr show dev eth0                # print result
```

Same subnet as host 2 → no gateway. Identical for both modes: **the host doesn't know there's a tunnel**.

## Router 2

Exactly the same with addresses mirrored: `local 10.1.1.2`, `remote 10.1.1.1`.

| | router-mlakhdar-1 | router-mlakhdar-2 |
|---|---|---|
| eth0 | 10.1.1.1/24 | 10.1.1.2/24 |
| `local` | 10.1.1.1 | 10.1.1.2 |
| `remote` (static) | 10.1.1.2 | 10.1.1.1 |
| `group` (multicast) | 239.1.1.1 | 239.1.1.1 |
