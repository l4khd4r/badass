---
tags: [concept, routing, bgp]
aliases: [Border Gateway Protocol]
---

# BGP — Border Gateway Protocol

← [[Concept Map]] · Used in [[P3 - BGP and the Route Reflector]]

The routing protocol **of the Internet**: it exchanges reachability between **Autonomous Systems** (AS). It's a **path-vector** protocol: each route carries the list of ASes it crossed (`AS_PATH`), which is used for loop prevention and policy.

## Essentials

| Thing | Value |
|---|---|
| Transport | **TCP port 179** (reliable; BGP doesn't need to re-flood) |
| Neighbors | configured explicitly (`neighbor X remote-as N`), or dynamically (`bgp listen range`) |
| Messages | OPEN, UPDATE, KEEPALIVE, NOTIFICATION |
| States | Idle → Connect → Active → OpenSent → OpenConfirm → **Established** |
| Admin distance | eBGP 20, iBGP 200 |

## Path attributes (the ones you'll see)

| Attribute | Meaning |
|---|---|
| `NEXT_HOP` | where to send traffic — in EVPN, the VTEP |
| `AS_PATH` | ASes crossed (empty within one AS) |
| `LOCAL_PREF` | preference inside an AS (default 100) |
| `ORIGIN` | `i` IGP, `e` EGP, `?` incomplete |
| `ORIGINATOR_ID`, `CLUSTER_LIST` | added by a [[Route Reflector]] |
| Extended communities | **RT** (Route Target), **ET** (encapsulation) — see [[Route Distinguisher and Route Target]] |
| weight | FRR/Cisco local-only value; 32768 = locally originated |

## Why BGP in a data center?

- It scales to millions of routes.
- With [[MP-BGP]] it carries anything: IPv6, VPN routes, **EVPN** MAC routes.
- Rich policy (communities, RTs) to control who gets what.

Related: [[iBGP vs eBGP]] · [[Route Reflector]] · [[EVPN]]
