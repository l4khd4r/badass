---
tags: [concept, l2, linux]
aliases: [br0, bridge, software switch]
---

# Linux bridge (`br0`)

← [[Concept Map]]

A **software Ethernet switch** inside the Linux kernel. Interfaces added to it become its **ports**; it forwards frames between them using a learned MAC table (the **FDB**, forwarding database).

```sh
ip link add br0 type bridge     # create the switch
ip link set eth1 master br0     # plug a port
ip link set vxlan10 master br0  # plug another port (the tunnel)
ip link set br0 up
```

## In BADASS (P2 and P3 VTEPs)

```text
          ┌──────── br0 ────────┐
host ── eth1                 vxlan10 ══ tunnel ══ other VTEPs
          └─────────────────────┘
```

- A port in a bridge is **L2 only**: it carries no IP (the routers' host ports have none).
- The bridge doesn't know `vxlan10` is a tunnel — it's just another port. The VXLAN device does the encapsulation.

## FDB entries you'll see

```sh
bridge fdb show br br0
bridge fdb show dev vxlan10
```

| Entry flag | Meaning |
|---|---|
| `master br0` | entry in the bridge's table: MAC → port |
| `self` | entry in the device's own table (for vxlan: MAC → remote VTEP `dst`) |
| `permanent` | static, never ages |
| `extern_learn` | installed by a control plane (FRR/EVPN), not learned from traffic |
| (none) | dynamically learned, ages out after 300 s |

Other useful commands: `bridge link` (ports + state), `brctl show` (legacy, from `bridge-utils`).
