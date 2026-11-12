---
tags: [concept, routing, ospf]
aliases: [Open Shortest Path First]
---

# OSPF — Open Shortest Path First

← [[Concept Map]] · Used in [[P3 - Underlay with OSPF]]

An **IGP** (Interior Gateway Protocol) of the **link-state** family.

## Link-state in one paragraph

Every router describes **its own links** in LSAs and floods them to all routers in the area. Everyone builds the **same map** (LSDB), then each runs **Dijkstra (SPF)** with itself as root to compute the shortest path to every prefix. Compare with distance-vector (RIP), where routers only share "I can reach X at distance N".

## Essentials

| Thing | Value |
|---|---|
| Transport | directly over IP, protocol **89** |
| Hello destination | **224.0.0.5** (all OSPF routers); 224.0.0.6 = DR/BDR |
| Hello / Dead timers | 10 s / 40 s (broadcast networks) |
| Router-id | 32-bit unique id; usually the loopback |
| Area 0 | the **backbone**; all other areas must connect to it. BADASS uses only area 0 |
| Metric | **cost** = reference bandwidth / interface bandwidth; summed along the path |
| Admin distance | 110 |

## Neighbor states

`Down → Init → 2-Way → ExStart → Exchange → Loading → Full`

- **2-Way**: each sees itself in the other's Hello.
- **ExStart/Exchange**: agree who leads, exchange LSDB summaries.
- **Loading**: request missing LSAs.
- **Full**: databases synchronized. ✅

Adjacency fails if: different area, different subnet/mask, different Hello/Dead timers, duplicate router-id, MTU mismatch.

## FRR commands

```sh
vtysh -c "show ip ospf neighbor"
vtysh -c "show ip ospf interface"
vtysh -c "show ip ospf database"
vtysh -c "show ip route ospf"
```

## OSPF vs IS-IS

Both are link-state IGPs. IS-IS runs directly over L2 (not IP), is popular in large ISPs and data centers. The router image enables `isisd` because the subject requires it, but BADASS configures OSPF.
