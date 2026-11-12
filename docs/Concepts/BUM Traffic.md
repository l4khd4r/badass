---
tags: [concept, vxlan, l2]
aliases: [BUM]
---

# BUM traffic

← [[Concept Map]]

**B**roadcast, **U**nknown unicast, **M**ulticast — frames a switch can't send to one known port, so it must **flood** them.

| Kind | Example | Why flooded |
|---|---|---|
| Broadcast | [[ARP]] request to `ff:ff:ff:ff:ff:ff` | meant for everyone |
| Unknown unicast | frame to a MAC not (yet) in the MAC table | switch doesn't know the port |
| Multicast | IPv6 ND, MLD, `01:00:5e:…` | multiple receivers |

## How a VTEP handles BUM

| Method | Used in | How |
|---|---|---|
| **Unicast to one peer** | P2 static | `remote 10.1.1.2` |
| **Underlay multicast** | P2 multicast | send once to `239.1.1.1`; the network delivers to every VTEP that joined. Needs multicast routing (PIM) if VTEPs aren't on one subnet |
| **Ingress / head-end replication** | P3 EVPN | the sending VTEP makes **one unicast copy per remote VTEP**, using the list learned from EVPN **type 3** routes |

Kernel view: these are the `00:00:00:00:00:00 dev vxlan10 dst X` FDB entries.

Related: [[Flood and Learn]] · [[EVPN]]
