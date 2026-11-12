---
tags: [concept, vxlan]
aliases: [VXLAN Network Identifier]
---

# VNI — VXLAN Network Identifier

← [[Concept Map]] · [[VXLAN]]

A **24-bit number** in the VXLAN header that says *which virtual L2 segment* a frame belongs to. Like a VLAN ID, but with ~16.7 million values instead of 4094.

- Both VTEPs must use the **same VNI** for frames to be accepted (`ip link add ... id 10`).
- One VNI = one broadcast domain = (usually) one subnet. In BADASS: **VNI 10** = 30.1.1.0/24 in P2, 20.1.1.0/24 in P3.
- In EVPN, the Route Target is auto-derived from it: `AS:VNI` → `1:10` (see [[Route Distinguisher and Route Target]]).
- Multi-tenancy: tenant A on VNI 10, tenant B on VNI 20 — same physical network, fully separated L2 domains.

Check: `ip -d link show vxlan10` → `vxlan id 10`; in FRR `show evpn vni`.
