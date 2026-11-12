---
tags: [badass, p2, verify, troubleshooting]
---

# P2 — Verification & troubleshooting

← [[P2 - Overview]] · All commands: [[Commands Cheatsheet]]

## Checklist (in order: underlay first, then overlay)

| # | Where | Command | Expected |
|---|---|---|---|
| 1 | router1 | `ping -c 2 10.1.1.2` | replies → underlay OK |
| 2 | router | `ip -d link show vxlan10` | `vxlan id 10 remote 10.1.1.2 ... dstport 4789` (static) or `group 239.1.1.1` (multicast) |
| 3 | router | `bridge link` | `eth1` and `vxlan10` both `master br0 state forwarding` |
| 4 | host1 | `ping -c 4 30.1.1.2` | replies, **`ttl=64`** |
| 5 | router | `bridge fdb show br br0 \| grep vxlan10` | learned MACs (table below) |

> [!tip] Why `ttl=64` matters
> Linux sends with TTL 64. Each **router** hop decrements it. Receiving 64 proves no IP router
> touched the inner packet: the hosts really are on one L2 segment. The routers act as switches here.

## Reading `bridge fdb`

| Entry | Meaning |
|---|---|
| `<host2 MAC> dev vxlan10 master br0` | bridge table: host2 is behind the tunnel port |
| `<host2 MAC> dev vxlan10 dst 10.1.1.2 self` | VXLAN table: send frames for that MAC to VTEP 10.1.1.2 |
| `00:00:00:00:00:00 dev vxlan10 dst 10.1.1.2` | static: the default destination for BUM |
| `00:00:00:00:00:00 dev vxlan10 dst 239.1.1.1 via eth0` | multicast: BUM goes to the group |

## Wireshark

Capture the router ↔ Switch1 link in GNS3 (right-click the link → *Start capture*), filter `vxlan`:

- outer `10.1.1.1 ↔ 10.1.1.2`, UDP **4789**, VXLAN **VNI 10**
- inner `30.1.1.1 ↔ 30.1.1.2`, ICMP
- 148 bytes vs 98 → **50 bytes** of encapsulation ([[Encapsulation Overhead]])

## Troubleshooting table

| Symptom | Likely cause | Check |
|---|---|---|
| `Destination Host Unreachable` | ARP got no answer: the other host has no IP, or the tunnel is broken | `ip a` on the other host; then checks 1–3 |
| `NO-CARRIER` on an interface | cable plugged into the wrong port in GNS3 | hover the link in GNS3 to see port names |
| underlay OK, overlay fails | `eth1` or `vxlan10` not in `br0`, or down | `bridge link` |
| no packets at all in Wireshark with filter `vxlan` | different port (8472 vs 4789) or different VNI | `ip -d link show vxlan10` on **both** routers |
| replies leave by the wrong interface | two routes for 30.1.1.0/24 on the host | `ip route` on the host |
| everything broke after a GNS3 restart | runtime config lost | re-run `./P2/deploy.sh <mode>` |

## Resources

- https://ipwithease.com/difference-between-underlay-network-and-overlay-network/
- https://ipwithease.com/vteps-and-vnis-in-vxlan/
- RFC 7348 — VXLAN
