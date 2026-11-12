---
tags: [concept, evpn, bgp]
aliases: [RD, RT, Route Distinguisher, Route Target]
---

# Route Distinguisher (RD) and Route Target (RT)

← [[Concept Map]] · [[EVPN]]

Two values that look similar but do **different jobs**.

| | Route Distinguisher | Route Target |
|---|---|---|
| Job | make a route **unique** | decide **who imports** a route |
| Where | part of the route key (NLRI) | an extended community attribute |
| Analogy | the sender's return address | the mailing list the letter is for |
| BADASS value | `1.1.1.2:2` (router-id : local index) | `1:10` (AS : VNI) |
| Configured? | auto-derived by FRR | auto-derived by FRR |

## Why RD exists

Two leaves could advertise the **same** MAC (VM moved, or two tenants with overlapping addresses). Without an RD, BGP would see the same key and keep only one. With different RDs, both routes exist and the receiver can choose.

## How RT works

- A leaf **exports** its VNI 10 routes with RT `1:10`.
- A leaf **imports** routes whose RT matches one of its local VNIs' import RTs.
- Tenant on VNI 20 would get RT `1:20` → never mixed with VNI 10.

Check: `vtysh -c "show bgp l2vpn evpn vni"` / `show evpn vni 10` show the RD and import/export RTs.
