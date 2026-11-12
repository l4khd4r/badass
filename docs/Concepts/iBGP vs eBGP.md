---
tags: [concept, bgp]
aliases: [iBGP, eBGP, AS, Autonomous System]
---

# iBGP vs eBGP

← [[Concept Map]] · [[BGP]]

An **Autonomous System (AS)** is a network under one administration, identified by an AS number (ASN). BADASS's whole fabric is **AS 1**.

| | iBGP | eBGP |
|---|---|---|
| Peers in | the **same** AS | **different** ASes |
| AS_PATH | unchanged | sender prepends its ASN |
| Loop prevention | **don't re-advertise iBGP-learned routes to iBGP peers** | drop routes containing your own ASN |
| Consequence | needs a **full mesh** or a [[Route Reflector]] | none |
| Next hop | unchanged by default | set to self |
| Admin distance | 200 | 20 |
| Typical peering | loopback to loopback (`update-source lo`), needs an IGP | directly connected interfaces |

## The full-mesh problem

n routers → n(n−1)/2 sessions.

| Leaves | Sessions (full mesh) | With 1 RR |
|---|---|---|
| 3 | 3 | 3 |
| 10 | 45 | 10 |
| 100 | 4950 | 100 |

## In BADASS

`neighbor ... remote-as 1` while being in `router bgp 1` → iBGP. That's why the project needs:
- [[OSPF]] (to reach the loopbacks used as session endpoints),
- a [[Route Reflector]] (to avoid the full mesh).

Many production fabrics use **eBGP** instead (one ASN per leaf, RFC 7938) and skip the IGP — a different but equally valid design.
