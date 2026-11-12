---
tags: [reference, evaluation]
aliases: [Evaluation questions]
---

# Defense Q&A

← [[00 Home]]

Questions an evaluator is likely to ask, with short answers and a link to the detail. Fold each callout to quiz yourself.

## P1

> [!question]- Why Alpine / BusyBox?
> Tiny images, fast to start many nodes; BusyBox provides the basic userland the subject asks for. → [[P1 - Host Image]]

> [!question]- Why is there no IP address in the images?
> Subject requirement, and good design: images are generic, configuration is per node via scripts. → [[P1 - Overview]]

> [!question]- What does each FRR daemon do?
> zebra = kernel interface/route installer; bgpd = BGP; ospfd = OSPF; isisd = IS-IS; staticd, mgmtd = core; watchfrr supervises. → [[FRRouting]]

> [!question]- What keeps the router container alive?
> `exec /bin/bash -i` makes an interactive shell PID 1; watchfrr runs in the background. → [[P1 - Router Image]]

> [!question]- What's the difference between a Docker image and a container?
> Image = frozen template; container = running instance with its own namespaces. → [[Docker in GNS3]]

## P2

> [!question]- What is VXLAN and why use it?
> Ethernet frames encapsulated in UDP/IP (port 4789) to stretch an L2 segment over an L3 network; 24-bit VNI. → [[VXLAN]]

> [!question]- What's a VTEP? A VNI?
> VTEP = endpoint that (de)encapsulates; VNI = segment id in the header. → [[VTEP]], [[VNI]]

> [!question]- Difference between static and multicast mode?
> Where BUM traffic goes: one fixed `remote` peer vs a multicast `group` all VTEPs join. Learning is flood-and-learn in both. → [[P2 - Overview#Two modes]]

> [!question]- Why does `eth1` on the router have no IP?
> It's a bridge port in `br0`: pure L2. → [[Linux Bridge]]

> [!question]- Why is the TTL 64 in the hosts' ping replies?
> No IP router decremented it: hosts are on the same L2 segment through the tunnel. → [[P2 - Verification and Troubleshooting]]

> [!question]- Why 148 bytes vs 98? Where do the 50 bytes come from?
> 14 outer Eth + 20 IP + 8 UDP + 8 VXLAN. → [[Encapsulation Overhead]]

> [!question]- Why `dstport 4789`?
> IANA port; Linux defaults to legacy 8472. → [[P2 - Script Walkthrough]]

> [!question]- Explain flood and learn with the first ping.
> ARP broadcast → flooded through tunnel → reply unicast → both VTEPs learn MAC→VTEP. → [[P2 - Packet Walk (Flood and Learn)]]

> [!question]- What's 239.1.1.1?
> An administratively-scoped multicast group the VTEPs join for BUM traffic. → [[BUM Traffic]]

## P3

> [!question]- What does each protocol do here?
> OSPF: reachability of loopbacks (underlay). BGP EVPN: announce VTEPs and MACs (overlay control). VXLAN: carry frames (overlay data). → [[P3 - Overview]]

> [!question]- Why loopbacks?
> Always up, stable identity: router-id, BGP source, VTEP address. → [[Loopback Interface]]

> [!question]- Why a route reflector?
> iBGP won't re-advertise iBGP-learned routes; RR avoids a full mesh (n(n−1)/2). → [[Route Reflector]], [[iBGP vs eBGP]]

> [!question]- Is the RR a VTEP? Does traffic go through it?
> Not a VTEP (no vxlan/bridge). Traffic physically crosses it because it's the only path, but it just routes the outer IP. Reflected routes keep the original next hop. → [[P3 - BGP and the Route Reflector]]

> [!question]- What does `bgp listen range 1.1.1.0/29` do?
> Dynamic neighbors: accept sessions from any 1.1.1.0–7 source and apply the peer-group. → [[P3 - BGP and the Route Reflector]]

> [!question]- What does `update-source lo` do?
> Source the BGP TCP session from the loopback so it matches the peer's config and survives link changes. → [[Loopback Interface]]

> [!question]- What does `advertise-all-vni` do?
> Makes the leaf advertise every local VNI (type 3) and its MACs (type 2), and install received ones. → [[P3 - Script Walkthrough]]

> [!question]- Explain type 2 and type 3.
> Type 3: "I'm a VTEP for VNI 10" → flood list. Type 2: "MAC X is behind me" → unicast destination. → [[P3 - EVPN Route Types]]

> [!question]- Why does a type 2 route appear before the host has an IP?
> EVPN here is L2: it advertises MACs. The host's port coming up emits IPv6 ND/MLD frames; the leaf's bridge learns the MAC. → [[P3 - EVPN Route Types#When each route appears (the subject's demo)]]

> [!question]- Why does a type 2 route disappear after a while?
> The MAC ages out of the bridge after 300 s without traffic → withdrawn. → [[P3 - EVPN Route Types]]

> [!question]- What do RD and RT mean in the output?
> RD makes routes unique (1.1.1.2:2); RT `1:10` decides import (AS:VNI). ET:8 = VXLAN. → [[Route Distinguisher and Route Target]]

> [!question]- Why `nolearning` and no `remote`/`group` in P3?
> Remote VTEPs come from type 3, remote MACs from type 2. → [[P3 - Script Walkthrough]]

> [!question]- Read `O>* 1.1.1.2/32 [110/20] via 10.1.1.9, eth2`.
> OSPF, best, installed; AD 110, cost 20 (2 hops × 10); next hop the RR. → [[P3 - Underlay with OSPF]]

> [!question]- What does `*>i` mean vs `*>` with weight 32768?
> `i` = learned from iBGP (reflected); 32768 = originated locally. → [[P3 - EVPN Route Types]]

> [!question]- How would you add a 4th leaf?
> New /30 to the RR (or a second RR), loopback 1.1.1.5 in OSPF, BGP to 1.1.1.1 (in listen range → no RR BGP change), vxlan10 + br0. Everyone learns it via type 3. → [[P3 - Overview]]

> [!question]- What happens if the RR dies?
> Underlay breaks too here (it's the only path). In general: control plane loses distribution; real designs use 2 RRs. → [[Route Reflector]]

> [!question]- How do you debug if hosts can't ping?
> Bottom-up: OSPF neighbors → loopback ping → BGP Established → EVPN routes → kernel FDB → host config. → [[P3 - Verification and Troubleshooting]]
