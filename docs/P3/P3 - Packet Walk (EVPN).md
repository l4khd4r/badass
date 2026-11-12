---
tags: [badass, p3, packet-walk, evpn, vxlan]
---

# P3 — Packet walk: from boot to `ping 20.1.1.2`

← [[P3 - Overview]]

The full life of the fabric, in order. Compare with [[P2 - Packet Walk (Flood and Learn)]].

## Phase 1 — Underlay converges (OSPF)

```mermaid
sequenceDiagram
    participant L2 as leaf 2 (1.1.1.2)
    participant RR as RR (1.1.1.1)
    participant L3 as leaf 3 (1.1.1.3)
    L2->>RR: OSPF Hello (224.0.0.5)
    RR->>L2: OSPF Hello
    L2-->>RR: adjacency → Full, exchange LSAs
    L3-->>RR: adjacency → Full, exchange LSAs
    Note over L2,L3: everyone runs SPF → routes to every 1.1.1.x /32 via the RR
```

Result: `1.1.1.2` can reach `1.1.1.3` (via 10.1.1.1 → 10.1.1.6). Details: [[P3 - Underlay with OSPF]].

## Phase 2 — BGP sessions come up

```mermaid
sequenceDiagram
    participant L2 as leaf 2
    participant RR as RR
    participant L3 as leaf 3
    L2->>RR: TCP 179 from 1.1.1.2 → 1.1.1.1, BGP OPEN (AS 1, EVPN capability)
    RR-->>L2: OPEN (accepted: 1.1.1.2 is in listen range 1.1.1.0/29)
    Note over L2,RR: Established
    L3->>RR: same from 1.1.1.3
    Note over L3,RR: Established
```

## Phase 3 — Type 3 routes (VTEP discovery)

```mermaid
sequenceDiagram
    participant L2 as leaf 2
    participant RR as RR
    participant L3 as leaf 3
    participant L4 as leaf 4
    L2->>RR: UPDATE type 3 [1.1.1.2] VNI 10 (RT 1:10)
    RR->>L3: reflect (next hop still 1.1.1.2)
    RR->>L4: reflect
    Note over L3,L4: zebra adds 00:00:00:00:00:00 dst 1.1.1.2 to vxlan10<br/>= "send BUM for VNI 10 to 1.1.1.2 too"
```

Each leaf now has a **flood list** = every other leaf. No multicast, no `remote` written by hand.

## Phase 4 — Host 1 comes up (type 2)

1. host-1's port goes up; it sends some frame (IPv6 ND, or later an ARP).
2. leaf 2's `br0` learns `MAC-H1 → eth1` (local learning still happens on the host port — `nolearning` only affects the VXLAN device).
3. zebra sees the new FDB entry → tells bgpd → bgpd sends **type 2 `[MAC-H1]`, next hop 1.1.1.2**.
4. RR reflects it to leaves 3 and 4.
5. Leaves 3 and 4 install `MAC-H1 dev vxlan10 dst 1.1.1.2 extern_learn`.

Same for hosts 2 and 3. **Every leaf knows every MAC before any ping.**

## Phase 5 — `ping 20.1.1.2` from host 1

```mermaid
sequenceDiagram
    participant H1 as host1 20.1.1.1
    participant L2 as leaf 2 VTEP 1.1.1.2
    participant RR as RR (just routes)
    participant L3 as leaf 3 VTEP 1.1.1.3
    participant H2 as host2 20.1.1.2
    H1->>L2: ARP who-has 20.1.1.2 (broadcast)
    Note over L2: BUM → ingress replication to flood list
    L2->>RR: VXLAN 1.1.1.2→1.1.1.3
    RR->>L3: (routed, not opened)
    L2->>RR: VXLAN 1.1.1.2→1.1.1.4 (copy, leaf 4 drops it as no one answers)
    L3->>H2: ARP request
    H2->>L3: ARP reply → MAC-H1
    Note over L3: MAC-H1 already known from type 2 → dst 1.1.1.2
    L3->>RR: VXLAN 1.1.1.3→1.1.1.2
    RR->>L2: (routed)
    L2->>H1: ARP reply
    H1->>L2: ICMP echo → MAC-H2
    Note over L2: MAC-H2 known from type 2 → dst 1.1.1.3, unicast
    L2->>RR: VXLAN 1.1.1.2→1.1.1.3
    RR->>L3: (routed)
    L3->>H2: ICMP echo
```

> [!note] ARP is still a broadcast
> EVPN doesn't remove ARP by itself; the ARP request is still BUM, replicated to every VTEP in the
> flood list. What disappears is the *unknown unicast* flooding and the *data-plane learning*.
> (Real fabrics add "ARP suppression" with MAC+IP type 2 routes so the leaf answers ARP locally —
> not configured in this project.)

## The packet on the RR ↔ leaf 2 link

![[p3-wireshark.png]]

```text
Eth │ IP 1.1.1.2 → 1.1.1.3 │ UDP src=<hash> dst=4789 │ VXLAN VNI 10 ║ Eth H1→H2 │ IP 20.1.1.1→20.1.1.2 │ ICMP
```

- Outer IPs are **loopbacks** — reachable only thanks to OSPF.
- The RR forwards it by looking at the **outer** IP only. It never opens the envelope.
- 148 bytes per ping frame = 98 + **50** ([[Encapsulation Overhead]]), same as P2.
- The outer UDP **source port** is a hash of the inner flow → different flows take different paths when there are several equal-cost paths (ECMP). Here there's one path, so it doesn't matter.

![[p3-ping.png]]
