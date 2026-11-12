---
tags: [concept, vxlan, overlay]
aliases: [Virtual Extensible LAN]
---

# VXLAN — Virtual Extensible LAN

← [[Concept Map]] · RFC 7348 (VXLAN), RFC 8365 (EVPN over VXLAN)

**VXLAN** carries **Layer-2 Ethernet frames inside UDP/IP packets**, so an L2 segment can stretch across a routed L3 network.

## Header stack

```text
┌─────────────────────────── added by the sending VTEP ──────────────────────────┐
│ Outer Ethernet (14) │ Outer IPv4 (20) │ Outer UDP (8), dst 4789 │ VXLAN (8)   │ Original Ethernet frame ...
└────────────────────────────────────────────────────────────────────────────────┘
```

VXLAN header (8 bytes):

```text
 0               8                              32
┌───────────────┬──────────────────────────────┐
│ Flags (I=1)   │ Reserved (24 bits)           │
├───────────────┴──────────────┬───────────────┤
│ VNI (24 bits)                │ Reserved (8)  │
└──────────────────────────────┴───────────────┘
```

- `I` flag = "the VNI field is valid".
- [[VNI]]: 24 bits → ~16.7 million segments.

## Key facts

| Fact | Value |
|---|---|
| Transport | UDP |
| Standard port | **4789** (Linux default without `dstport` is 8472, legacy) |
| Overhead | **50 bytes** over IPv4 → [[Encapsulation Overhead]] |
| Endpoint name | [[VTEP]] |
| Outer UDP source port | hash of the inner flow → load balancing (ECMP) in the underlay |
| Handles BUM by | `remote` (head-end to 1 peer), `group` (multicast), or a control plane like [[EVPN]] |

## Linux

```sh
ip link add vxlan10 type vxlan id 10 local <my-ip> [remote <peer> | group <mcast>] dstport 4789 [dev eth0] [nolearning]
ip -d link show vxlan10
bridge fdb show dev vxlan10
```

A VXLAN interface on its own is a "pipe"; you plug it into a [[Linux Bridge]] with the host port to make a VTEP that switches.

## In BADASS

- P2: [[P2 - Overview]] — static / multicast, [[Flood and Learn]]
- P3: [[P3 - Overview]] — EVPN-driven, `nolearning`, loopback as `local`

## VXLAN vs VLAN

| | VLAN (802.1Q) | VXLAN |
|---|---|---|
| ID size | 12 bits → 4094 | 24 bits → 16M |
| Scope | one L2 domain | anywhere IP reaches |
| Where the tag lives | inside the Ethernet header | in a UDP payload |
