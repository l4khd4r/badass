---
tags: [concept]
aliases: [Control plane, Data plane]
---

# Control plane vs data plane

← [[Concept Map]]

| | Control plane | Data plane (forwarding plane) |
|---|---|---|
| Job | **decide**: build the tables | **carry**: forward each packet using the tables |
| Speed | slow-ish, event-driven | per packet, fast path |
| In a router | routing protocols (FRR daemons) | the kernel / ASIC |

## BADASS P3 mapped

| Plane | Underlay | Overlay |
|---|---|---|
| Control | **OSPF** (ospfd) → routes to loopbacks | **BGP EVPN** (bgpd) → VTEP list, remote MACs |
| Data | Linux IP forwarding (`ip route`) | **VXLAN** device + **bridge** FDB |
| Glue | **zebra** installs both into the kernel | |

> [!quote]
> "OSPF and BGP **decide**, VXLAN **carries**."

In P2 there is **no separate control plane** for the overlay: the data plane learns by itself ([[Flood and Learn]]). That's the fundamental difference between P2 and P3.
