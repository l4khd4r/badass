---
tags: [concept, l2]
aliases: [MAC, Ethernet, Layer 2]
---

# Ethernet and MAC addresses

← [[Concept Map]]

**Layer 2** = delivery inside one local network (one broadcast domain), using **MAC addresses**.

- MAC = 48 bits, written `02:42:aa:20:a5:01`. First 3 bytes often identify the vendor; `02:42:…` is Docker's range (locally administered).
- `ff:ff:ff:ff:ff:ff` = broadcast (everyone on the segment).
- Ethernet frame: `dst MAC | src MAC | EtherType (0x0800 IPv4, 0x0806 ARP, 0x86dd IPv6) | payload | FCS`.

## L2 vs L3

| | Layer 2 (switching) | Layer 3 (routing) |
|---|---|---|
| Address | MAC | IP |
| Device | switch / bridge | router |
| Decision | MAC table (learned) | routing table (configured / protocols) |
| Scope | one broadcast domain | between networks |
| TTL decremented? | no | yes |

**The whole point of VXLAN** is to give hosts an L2 segment (same subnet, ARP works, TTL untouched) over an L3 network.

Related: [[ARP]] · [[Linux Bridge]] · [[BUM Traffic]] · [[Routing Basics]]
