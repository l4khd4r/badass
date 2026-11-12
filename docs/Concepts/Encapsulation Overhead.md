---
tags: [concept, vxlan, mtu]
aliases: [MTU, 50 bytes]
---

# Encapsulation overhead (the "50 bytes")

← [[Concept Map]] · [[VXLAN]]

## The count

| Added header | Bytes |
|---|---|
| Outer Ethernet | 14 |
| Outer IPv4 | 20 |
| Outer UDP | 8 |
| VXLAN | 8 |
| **Total** | **50** |

## In BADASS (Wireshark)

Default `ping`: 56 data bytes + 8 ICMP header = 64 → + 20 IP → 84 → + 14 Ethernet → **98 bytes**.
Encapsulated: 98 + 50 = **148 bytes** — exactly what P2 and P3 captures show.

## Why it matters: MTU

The inner frame (up to 1514 bytes with a 1500 MTU host) + 50 = 1564 bytes must fit in the underlay.
Options in real networks:
- raise the underlay MTU (e.g. 9000, "jumbo frames") — the common choice,
- or lower the host MTU to 1450.

In the lab small pings never hit the limit; a `ping -s 1472 -M do` from a host would reveal it.
