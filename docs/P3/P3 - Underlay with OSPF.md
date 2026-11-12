---
tags: [badass, p3, ospf, underlay]
---

# P3 — Underlay with OSPF

← [[P3 - Overview]] · Concept: [[OSPF]]

## Why an underlay protocol at all?

In P2 both VTEPs sat in one subnet, so the kernel's connected route was enough.
In P3:

- each leaf only shares a /30 with the RR,
- BGP sessions and VXLAN tunnels are between **loopbacks** (1.1.1.x/32), which are on **no** shared link.

Leaf 2 has no idea how to reach 1.1.1.3 unless someone tells it. **OSPF** does exactly that: every router advertises its links and its loopback, and every router computes a route to every prefix.

## The config (leaf 2 example)

```text
router ospf
 ospf router-id 1.1.1.2
!
interface eth0
 ip address 10.1.1.2/30
 ip ospf area 0
!
interface lo
 ip address 1.1.1.2/32
 ip ospf area 0
```

| Line | Meaning |
|---|---|
| `router ospf` | start an OSPF instance |
| `ospf router-id 1.1.1.2` | this router's unique name in the OSPF map. Using the loopback IP makes it readable and unique. **Duplicate router-ids break OSPF** |
| `ip ospf area 0` (on an interface) | enable OSPF on that interface in the **backbone area**: send Hellos, form adjacencies, and advertise its subnet |
| on `lo` | advertise the /32 loopback (no neighbor will ever appear on it, it's just advertised) |
| the host port | **not** in OSPF and no IP: it belongs to the overlay |

The RR has the same with 3 links + its loopback. Every router is in **area 0** — a single-area design, fine for 4 routers.

## What happens on the wire

1. Each router sends **Hello** packets every 10 s to `224.0.0.5` (AllSPFRouters) on each OSPF interface.
2. When two routers see each other in their Hellos and agree on parameters (area, subnet, timers), they form an **adjacency**: `Init → 2-Way → ExStart → Exchange → Loading → Full`.
3. They exchange **LSAs** (Link-State Advertisements): "I am 1.1.1.2, I have link 10.1.1.0/30 and stub 1.1.1.2/32".
4. Every router ends up with the **same map** (LSDB) and runs **Dijkstra (SPF)** to compute shortest paths.
5. ospfd hands the best routes to **zebra**, which installs them in the Linux kernel.

You can see the Hellos in Wireshark: `10.1.1.x → 224.0.0.5`, protocol OSPF (IP protocol 89). ![[p3-wireshark.png]]

## Result: routing table on router-4

```text
O>* 1.1.1.1/32 [110/10] via 10.1.1.9, eth2
O>* 1.1.1.2/32 [110/20] via 10.1.1.9, eth2
O>* 1.1.1.3/32 [110/20] via 10.1.1.9, eth2
O>* 10.1.1.0/30 [110/20] via 10.1.1.9, eth2
O>* 10.1.1.4/30 [110/20] via 10.1.1.9, eth2
```

| Piece | Meaning |
|---|---|
| `O` | learned by OSPF |
| `>` | selected as best |
| `*` | installed in the kernel (FIB) |
| `[110/20]` | **administrative distance** 110 (OSPF's trust level) / **metric** 20 (sum of link costs: leaf→RR→leaf = 10 + 10) |
| `via 10.1.1.9, eth2` | next hop = the RR. The only way out of this leaf |

Administrative distance reminder: connected 0, static 1, eBGP 20, **OSPF 110**, IS-IS 115, iBGP 200. Lower wins when two protocols offer the same prefix.

## Why OSPF and not BGP for the underlay?

You *could* (many big fabrics use eBGP everywhere). Here the subject separates the roles to make the layering obvious:

- OSPF = fast, automatic, link-state, perfect for "make all loopbacks reachable" in a small single-admin network.
- BGP = policy-rich, scalable, carries arbitrary information (EVPN) — used for the overlay.

## Checks

```sh
vtysh -c "show ip ospf neighbor"     # state Full/... with the RR
vtysh -c "show ip ospf interface"
vtysh -c "show ip route ospf"
ping -c 2 -I 1.1.1.2 1.1.1.3         # loopback to loopback: proves the underlay works for VXLAN
```
