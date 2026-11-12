---
tags: [reference, glossary]
---

# Glossary

← [[00 Home]]

| Term | Meaning | Note |
|---|---|---|
| **AD** (administrative distance) | trust level of a route source; lower wins (OSPF 110, iBGP 200) | [[Routing Basics]] |
| **AFI/SAFI** | identifiers of a BGP address family; EVPN = 25/70 | [[MP-BGP]] |
| **ARP** | IPv4 → MAC resolution, broadcast request | [[ARP]] |
| **AS / ASN** | Autonomous System / its number; BADASS = AS 1 | [[iBGP vs eBGP]] |
| **BGP** | path-vector routing protocol of the Internet, TCP 179 | [[BGP]] |
| **Bridge** | software switch (`br0`) | [[Linux Bridge]] |
| **BUM** | Broadcast, Unknown unicast, Multicast | [[BUM Traffic]] |
| **Control plane** | the part that builds forwarding tables | [[Control Plane vs Data Plane]] |
| **Data plane** | the part that forwards packets | [[Control Plane vs Data Plane]] |
| **ECMP** | Equal-Cost Multi-Path: load-balance across equal paths | [[VXLAN]] |
| **eBGP / iBGP** | BGP between ASes / inside one AS | [[iBGP vs eBGP]] |
| **EVPN** | BGP family advertising MACs/VTEPs; overlay control plane | [[EVPN]] |
| **extern_learn** | FDB flag: entry installed by a control plane | [[Linux Bridge]] |
| **FDB** | Forwarding DataBase: a bridge's MAC table | [[Linux Bridge]] |
| **Flood and learn** | discover MACs by flooding unknowns and watching replies | [[Flood and Learn]] |
| **FRR** | FRRouting, the routing suite in the router image | [[FRRouting]] |
| **GNS3** | network emulator used to wire containers | [[Docker in GNS3]] |
| **Head-end / ingress replication** | VTEP sends one unicast copy of BUM per remote VTEP | [[BUM Traffic]] |
| **IGP** | Interior Gateway Protocol (OSPF, IS-IS) | [[OSPF]] |
| **IMET** | Inclusive Multicast Ethernet Tag = EVPN type 3 | [[P3 - EVPN Route Types]] |
| **IS-IS** | link-state IGP; daemon enabled, not configured | [[P1 - FRR Configuration Files]] |
| **Leaf** | access switch/router where hosts connect; a VTEP | [[P3 - Overview]] |
| **Loopback** | always-up virtual interface; router identity | [[Loopback Interface]] |
| **LSA / LSDB** | OSPF link-state advertisement / database | [[OSPF]] |
| **MP-BGP** | BGP with address families | [[MP-BGP]] |
| **MTU** | max packet size on a link; VXLAN adds 50 bytes | [[Encapsulation Overhead]] |
| **Multicast group** | address (239.1.1.1) receivers join | [[P2 - Overview]] |
| **nolearning** | VXLAN option: don't learn remote MACs from traffic | [[P3 - Script Walkthrough]] |
| **Overlay / underlay** | virtual network on top / real network below | [[Underlay vs Overlay]] |
| **RD** | Route Distinguisher: makes a route unique | [[Route Distinguisher and Route Target]] |
| **RR** | Route Reflector | [[Route Reflector]] |
| **RT** | Route Target: decides who imports | [[Route Distinguisher and Route Target]] |
| **Router-id** | 32-bit unique id of an OSPF/BGP router | [[Loopback Interface]] |
| **SPF** | Shortest Path First (Dijkstra), run by OSPF | [[OSPF]] |
| **Spine** | core switches connecting leaves (the RR plays this position here) | [[P3 - Overview]] |
| **Type 2 / type 3** | EVPN MAC/IP route / VTEP announcement | [[P3 - EVPN Route Types]] |
| **VNI** | 24-bit VXLAN segment id | [[VNI]] |
| **VTEP** | VXLAN Tunnel Endpoint | [[VTEP]] |
| **vtysh** | FRR's unified CLI | [[P1 - FRR Configuration Files]] |
| **VXLAN** | Ethernet in UDP 4789 | [[VXLAN]] |
| **watchfrr** | FRR supervisor that starts/restarts daemons | [[P1 - Router Image]] |
| **zebra** | FRR daemon talking to the kernel | [[FRRouting]] |
