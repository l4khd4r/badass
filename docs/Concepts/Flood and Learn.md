---
tags: [concept, vxlan, l2]
---

# Flood and learn

← [[Concept Map]]

The way a classic Ethernet switch — and a VXLAN VTEP **without a control plane** — discovers where MACs are.

1. A frame arrives → record **source MAC → incoming port** (learn).
2. Destination MAC known → send to that port only.
3. Destination unknown / broadcast → send to **all** ports except the incoming one (flood).
4. Entries expire after an **aging time** (300 s on Linux bridges).

For a VTEP, "port" also means "remote VTEP IP": when a VXLAN packet arrives from 10.1.1.2 carrying source MAC X, the VTEP learns "X is behind 10.1.1.2".

## Pros / cons

| ✅ | ❌ |
|---|---|
| zero configuration | flooding grows with the number of VTEPs |
| works everywhere | learning is reactive (after the first flood) |
| | needs multicast in the underlay or a hand-written peer list |
| | no control: any MAC seen is believed |

BADASS: used in [[P2 - Packet Walk (Flood and Learn)]], replaced by [[EVPN]] in P3 (`nolearning` on `vxlan10`).
