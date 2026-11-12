---
tags: [concept, l3, routing]
aliases: [Routing table, FIB, RIB]
---

# Routing basics

← [[Concept Map]]

A router forwards an IP packet by looking up the **destination IP** in its routing table and choosing the **longest matching prefix**.

## Where routes come from

| Source | Example | Admin distance |
|---|---|---|
| Connected | adding 10.1.1.2/30 to eth0 creates `10.1.1.0/30 dev eth0` | 0 |
| Static | `ip route add …` | 1 |
| eBGP | | 20 |
| **OSPF** | `O>* 1.1.1.3/32 via 10.1.1.9` | **110** |
| IS-IS | | 115 |
| **iBGP** | | **200** |

**Administrative distance** = how much a router trusts a source when two give the same prefix (lower wins). **Metric** = the cost *within* one protocol.

## RIB vs FIB in FRR

- **RIB** (Routing Information Base): all routes known by FRR — `vtysh -c "show ip route"`.
- **FIB** (Forwarding Information Base): what the kernel actually uses — `ip route`.
- **zebra** selects the best RIB routes and installs them in the FIB (`*` in `O>*`).

## In BADASS

- P2: only connected routes needed (both VTEPs in 10.1.1.0/24).
- P3: [[OSPF]] fills the routes to every loopback. BGP doesn't install IP routes here (the EVPN AF produces MAC/VTEP entries instead).
