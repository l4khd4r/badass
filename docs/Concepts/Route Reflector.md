---
tags: [concept, bgp]
aliases: [RR]
---

# Route reflector

← [[Concept Map]] · RFC 4456 · Used in [[P3 - BGP and the Route Reflector]]

An iBGP speaker allowed to **re-advertise** ("reflect") routes between its **clients**, breaking the iBGP no-readvertise rule in a controlled way → each client needs **one** session to the RR instead of a full mesh.

## Reflection rules

| Route learned from | Reflected to |
|---|---|
| a client | all other clients + non-clients |
| a non-client | clients only |
| an eBGP peer | everyone |

## Loop prevention

- `ORIGINATOR_ID`: router-id of the original sender. A router that sees its own id drops the route.
- `CLUSTER_LIST`: RR cluster ids crossed. An RR that sees its own cluster id drops it.

## Key property

The RR **does not change the next hop**. Clients still send traffic **directly** to the originator. The RR is a **control-plane** device; it doesn't need to be in the data path (in BADASS it happens to be, only because it's the physical hub).

## Redundancy

Real fabrics use **two** RRs (often the spine switches) so that losing one doesn't stop route distribution. BADASS has one → a single point of failure for the control plane (existing forwarding keeps working until routes expire).

## FRR config

```text
router bgp 1
 neighbor ibgp peer-group
 neighbor ibgp remote-as 1
 neighbor ibgp update-source lo
 bgp listen range 1.1.1.0/29 peer-group ibgp
 address-family l2vpn evpn
  neighbor ibgp activate
  neighbor ibgp route-reflector-client
```
