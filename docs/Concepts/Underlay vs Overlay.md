---
tags: [concept, overlay]
aliases: [Underlay, Overlay]
---

# Underlay vs Overlay

← [[Concept Map]]

| | Underlay | Overlay |
|---|---|---|
| What | the **real** network: routers, cables, IP addresses between devices | a **virtual** network built on top of it |
| Who uses it | the network devices (VTEPs) | the hosts / VMs / containers |
| In BADASS P2 | 10.1.1.0/24 | 30.1.1.0/24, VNI 10 |
| In BADASS P3 | 10.1.1.x/30 links + 1.1.1.x/32 loopbacks, OSPF | 20.1.1.0/24, VNI 10, BGP EVPN |
| In a packet | the **outer** headers | the **inner** headers |

## Analogy: a letter in an envelope

- The **overlay** packet is the letter: "from 30.1.1.1 to 30.1.1.2".
- The VTEP puts it in an **envelope** (the outer headers): "from 10.1.1.1 to 10.1.1.2".
- The post office (underlay routers, the switch, the RR in P3) reads only the envelope.
- The receiving VTEP opens the envelope and delivers the letter.

## Why build overlays?

- **Decoupling**: the hosts' addressing and L2 domains don't depend on the physical topology. Move a VM to another rack and it keeps its IP and its LAN.
- **Scale**: a routed underlay (L3) has no spanning tree, uses all links (ECMP), and limits failure domains. But applications sometimes want L2 adjacency → overlay gives both.
- **Multi-tenancy**: 16 million [[VNI|VNIs]] vs 4094 VLANs.

## Related
[[VXLAN]] · [[VTEP]] · [[Control Plane vs Data Plane]] · [[Encapsulation Overhead]]
