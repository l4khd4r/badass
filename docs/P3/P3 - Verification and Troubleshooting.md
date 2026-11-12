---
tags: [badass, p3, verify, troubleshooting]
---

# P3 — Verification & troubleshooting

← [[P3 - Overview]] · All commands: [[Commands Cheatsheet]]

> [!tip] Golden rule: debug bottom-up
> **Links → OSPF → loopback ping → BGP session → EVPN routes → kernel FDB → host ping.**
> Each layer depends on the one before. A BGP problem is very often an OSPF problem.

## 1. Underlay — OSPF

```sh
vtysh -c "show ip ospf neighbor"   # leaf: 1 neighbor (RR), RR: 3 neighbors, state Full
vtysh -c "show ip route"
```

Expected on router-4:

```text
O>* 1.1.1.1/32 [110/10] via 10.1.1.9, eth2
O>* 1.1.1.2/32 [110/20] via 10.1.1.9, eth2
O>* 1.1.1.3/32 [110/20] via 10.1.1.9, eth2
O>* 10.1.1.0/30 [110/20] via 10.1.1.9, eth2
O>* 10.1.1.4/30 [110/20] via 10.1.1.9, eth2
```

Then: `ping -c 2 -I 1.1.1.4 1.1.1.2` — loopback to loopback.

## 2. BGP sessions

```sh
vtysh -c "show bgp summary"
```

- Leaf: **one** neighbor `1.1.1.1`, in both *IPv4 Unicast* (activated by default with `frr defaults traditional`) and *L2VPN EVPN*.
- RR: three neighbors, shown with a `*` = **dynamic** (from `bgp listen range`).
- `State/PfxRcd` shows a **number** → Established. A word (`Active`, `Connect`, `Idle`) → not up.

## 3. EVPN routes

```sh
vtysh -c "show bgp l2vpn evpn"
vtysh -c "show evpn vni"            # VNI 10, type L2, VxLAN IF vxlan10, #remote VTEPs 2
vtysh -c "show evpn vni 10"         # list of remote VTEPs
vtysh -c "show evpn mac vni 10"     # local + remote MACs and where they are
```

| Stage | Expect |
|---|---|
| after `routers` | 3 × `[3]` (one per leaf), no `[2]` |
| after `hosts-noip` | + 3 × `[2]` (one per host MAC) |
| after 300 s of silence | `[2]` withdrawn again |

Decoding: [[P3 - EVPN Route Types]].

## 4. Kernel data plane

```sh
bridge fdb show dev vxlan10
#  00:00:00:00:00:00 dst 1.1.1.3 self permanent      ← flood list (from type 3)
#  00:00:00:00:00:00 dst 1.1.1.4 self permanent
#  <MAC-H2> dst 1.1.1.3 self extern_learn            ← from type 2
ip -d link show vxlan10           # vxlan id 10 local 1.1.1.2 dstport 4789 nolearning
bridge link                       # host port + vxlan10 in br0, forwarding
```

## 5. Hosts

```sh
ping -c 3 20.1.1.2      # from host-mlakhdar-1
ping -c 3 20.1.1.3
```

![[p3-ping.png]]

## 6. Wireshark (link RR ↔ router-2)

- `ospf` filter: Hellos `10.1.1.x → 224.0.0.5`
- `bgp` filter: OPEN / UPDATE / KEEPALIVE between `1.1.1.x` on TCP 179
- `vxlan` filter: outer `1.1.1.2 → 1.1.1.3`, UDP 4789, VNI 10, inner `20.1.1.1 → 20.1.1.2` ICMP

## Troubleshooting table

| Symptom | Likely cause | Check / fix |
|---|---|---|
| no `O` routes | OSPF adjacency not formed | `show ip ospf neighbor` must be `Full`; same area 0; unique router-ids; the right interface name in the script for that leaf (eth0/eth1/eth2) |
| BGP stuck in `Active`/`Connect` | loopback not reachable yet | `ping -I 1.1.1.x 1.1.1.1`; wait for OSPF; check `update-source lo` on both sides |
| RR refuses the leaf | leaf's source IP outside `1.1.1.0/29` | `show bgp neighbors`; verify `update-source lo` |
| no type 3 route | VNI not seen by zebra | `show evpn vni`: VNI 10 must be listed; `vxlan10` must be **in `br0` and up**; `advertise-all-vni` present |
| no type 2 route | host silent; MAC aged out | generate traffic from the host; `bridge fdb show br br0` on the leaf |
| type 2 exists but ping fails | wrong host port in the bridge, host IP in another subnet | `bridge link`; `ip a` on hosts |
| everything gone after GNS3 restart | runtime config lost | `./P3/deploy.sh` again |
| `deploy.sh: no eth0 - skipped` | project not started or cables not plugged yet | start nodes in GNS3, retry |
