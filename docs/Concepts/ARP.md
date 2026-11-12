---
tags: [concept, l2]
aliases: [Address Resolution Protocol]
---

# ARP — Address Resolution Protocol

← [[Concept Map]]

Translates an **IPv4 address → MAC address** on a local segment.

1. host1 wants to send to 30.1.1.2, which is in its own subnet.
2. It broadcasts: **"Who has 30.1.1.2? Tell 30.1.1.1"** (dst `ff:ff:ff:ff:ff:ff`).
3. host2 replies **unicast**: "30.1.1.2 is at `aa:bb:…`".
4. host1 caches it (`ip neigh`) and sends the IP packet in a frame to that MAC.

If the destination is in **another** subnet, the host ARPs for its **gateway** instead. In BADASS all hosts share one subnet → no gateway needed.

## Why it matters in this project

- The **first** packet of every conversation is an ARP **broadcast** → it's [[BUM Traffic]] → the VTEP must flood it across the tunnel.
- In P2 Wireshark multicast mode, this first ARP is the packet you see going to `239.1.1.1`.
- To replay it: `ip neigh flush all` on the host.

Commands: `ip neigh`, `arp -n` (net-tools), `tcpdump -n arp`.

IPv6 uses **Neighbor Discovery** (ICMPv6, multicast) instead — those are the frames that make P3 type 2 routes appear in `noip` mode.
