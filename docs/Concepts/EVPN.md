---
tags: [concept, evpn, bgp]
aliases: [Ethernet VPN, BGP EVPN]
---

# EVPN — Ethernet VPN

← [[Concept Map]] · RFC 7432 (EVPN), RFC 8365 (EVPN over VXLAN/NVO)

A **BGP address family** ([[MP-BGP]] AFI 25 / SAFI 70) used as the **control plane** for L2 (and L3) overlays. Instead of discovering MACs by flooding, each VTEP **announces** what it has.

## Route types

| Type | Name | Purpose | In BADASS |
|---|---|---|---|
| 1 | Ethernet Auto-Discovery | multihoming (a host connected to 2 leaves) | — |
| **2** | **MAC/IP Advertisement** | "MAC X (optionally IP Y) is behind me" | ✅ |
| **3** | **Inclusive Multicast Ethernet Tag** | "I'm a VTEP for this VNI, send me BUM" | ✅ |
| 4 | Ethernet Segment | multihoming DF election | — |
| 5 | IP Prefix | L3 routing between subnets/VNIs | — |

## What EVPN gives over flood-and-learn

| Problem in P2 | EVPN answer |
|---|---|
| peers written by hand / multicast underlay | **type 3** auto-discovery + ingress replication |
| MACs learned only after flooding | **type 2** advertised as soon as a MAC is seen locally |
| no control over what's learned | BGP policy, Route Targets |
| VM moves are slow to converge | MAC mobility sequence numbers in type 2 |
| ARP floods everywhere | (option) ARP suppression with MAC+IP type 2 |

## EVPN is "just" a control plane

It doesn't carry traffic. The data plane can be **VXLAN** (BADASS), MPLS, or others. The subject says "EVPN over VXLAN **without MPLS**".

Deep dive: [[P3 - EVPN Route Types]] · [[Route Distinguisher and Route Target]] · [[Control Plane vs Data Plane]]
