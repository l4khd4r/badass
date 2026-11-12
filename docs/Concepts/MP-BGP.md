---
tags: [concept, bgp]
aliases: [Multiprotocol BGP, address family, AFI, SAFI]
---

# MP-BGP — Multiprotocol BGP

← [[Concept Map]] · RFC 4760

Original BGP only carried IPv4 prefixes. **MP-BGP** adds **address families**, each identified by an **AFI/SAFI** pair, so the same BGP session can carry many kinds of information.

| Address family | AFI / SAFI | FRR keyword |
|---|---|---|
| IPv4 unicast | 1 / 1 | `address-family ipv4 unicast` |
| IPv6 unicast | 2 / 1 | `address-family ipv6 unicast` |
| L3VPN | 1 / 128 | `address-family ipv4 vpn` |
| **EVPN** | **25 / 70** | **`address-family l2vpn evpn`** |

## How it works

- In the **OPEN** message, each side announces the families it supports (*capabilities*). Only common families are used.
- Routes are carried in the `MP_REACH_NLRI` / `MP_UNREACH_NLRI` attributes of UPDATE messages.
- In FRR, a neighbor must be **activated** per family: `address-family l2vpn evpn / neighbor X activate`.

In BADASS, `show bgp summary` lists the neighbor under both *IPv4 Unicast* (activated by default with `frr defaults traditional`, but nothing advertised) and *L2VPN EVPN* (where the real routes are).

Related: [[EVPN]] · [[BGP]]
