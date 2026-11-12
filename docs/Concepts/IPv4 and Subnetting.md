---
tags: [concept, l3, ip]
aliases: [Subnetting, CIDR]
---

# IPv4 and subnetting

← [[Concept Map]]

An IPv4 address is 32 bits. The **prefix length** `/n` says how many leading bits are the **network** part; the rest is the **host** part.

| Prefix | Mask | Addresses | Usable hosts | BADASS use |
|---|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 | P2 underlay 10.1.1.0/24, overlays 30.1.1.0/24 and 20.1.1.0/24 |
| /29 | 255.255.255.248 | 8 | 6 | RR `bgp listen range 1.1.1.0/29` (= 1.1.1.0–1.1.1.7) |
| /30 | 255.255.255.252 | 4 | **2** | P3 point-to-point links |
| /32 | 255.255.255.255 | 1 | the address itself | loopbacks 1.1.1.x |

## The P3 /30s

| Subnet | Network | Usable | Broadcast |
|---|---|---|---|
| 10.1.1.0/30 | .0 | .1 (RR), .2 (leaf 2) | .3 |
| 10.1.1.4/30 | .4 | .5 (RR), .6 (leaf 3) | .7 |
| 10.1.1.8/30 | .8 | .9 (RR), .10 (leaf 4) | .11 |

A /30 is the classic choice for a link with exactly two routers: no wasted addresses beyond network+broadcast. (A /31 would be even tighter, RFC 3021.)

## Same subnet = no router needed

Two hosts in the same subnet talk directly via [[ARP]] and L2. That's why the overlay hosts need no gateway: VXLAN makes them truly share one L2 segment.

Related: [[Routing Basics]] · [[Loopback Interface]]
