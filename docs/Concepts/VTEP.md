---
tags: [concept, vxlan]
aliases: [VXLAN Tunnel Endpoint]
---

# VTEP — VXLAN Tunnel Endpoint

← [[Concept Map]] · [[VXLAN]]

The device that **encapsulates** frames into VXLAN on the way out and **decapsulates** them on the way in.

A VTEP needs to know:

1. **Its own address** (`local`) — the outer source IP.
2. **Where to send BUM traffic** — one peer, a multicast group, or a list of peers.
3. **Which remote VTEP owns which MAC** — learned from traffic or from a control plane.

| | P2 | P3 |
|---|---|---|
| VTEPs | router-mlakhdar-1, -2 | router-mlakhdar-2, -3, -4 (not the RR) |
| `local` | link IP 10.1.1.x | loopback 1.1.1.x → [[Loopback Interface]] |
| BUM destination (2) | `remote` / `group` | list built from EVPN **type 3** routes |
| MAC → VTEP (3) | [[Flood and Learn]] | EVPN **type 2** routes |

In Linux a VTEP = a `vxlan` interface + a [[Linux Bridge]] joining it with the host-facing port(s).

In hardware data centers the VTEP is typically the **leaf switch** (top-of-rack), or the hypervisor's virtual switch.
