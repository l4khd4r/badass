#!/bin/sh
# =============================================================================
# P3 - router-mlakhdar-1 : ROUTE REFLECTOR (RR)
#
# Role in the fabric:
#   - Underlay : connected to the 3 leaves by point-to-point /30 links.
#                OSPF advertises these links and every loopback, so all
#                routers can reach each other's loopback (1.1.1.x).
#   - Overlay  : iBGP in AS 1. Each leaf opens ONE session to this router.
#                As route reflector, it passes the EVPN routes of each leaf
#                to the other leaves, so no full mesh of sessions is needed.
#   - It is NOT a VTEP: no vxlan10, no bridge, no host behind it.
#                It still forwards the VXLAN packets between leaves (underlay).
#
# Interfaces:   eth0 -> router-mlakhdar-2   10.1.1.1/30
#               eth1 -> router-mlakhdar-3   10.1.1.5/30
#               eth2 -> router-mlakhdar-4   10.1.1.9/30
#               lo   -> loopback            1.1.1.1/32
#
# Everything is configured through vtysh (FRR shell), so it appears in
# "show running-config" and is saved in /etc/frr/frr.conf.
# =============================================================================

vtysh <<'VTY'
configure terminal
hostname router-mlakhdar-1
!
! ============================ OSPF (underlay) ================================
! Link-state protocol: every router learns the whole map of the network and
! computes the shortest path to every prefix (SPF / Dijkstra).
! The router-id is this router's name in the OSPF map; using the loopback
! address makes it unique and easy to read.
router ospf
 ospf router-id 1.1.1.1
exit
!
! ============================ Interfaces =====================================
! Each link to a leaf is a /30: 4 addresses = network, 2 hosts, broadcast.
! "ip ospf area 0" puts the interface in the backbone area: OSPF sends Hellos
! on it, forms an adjacency with the leaf, and advertises its subnet.
interface eth0
 ! link to router-mlakhdar-2
 ip address 10.1.1.1/30
 ip ospf area 0
exit
interface eth1
 ! link to router-mlakhdar-3
 ip address 10.1.1.5/30
 ip ospf area 0
exit
interface eth2
 ! link to router-mlakhdar-4
 ip address 10.1.1.9/30
 ip ospf area 0
exit
!
! Loopback: virtual interface that never goes down while the router is alive.
! It is the stable identity used by BGP. Advertised in OSPF so leaves reach it.
interface lo
 ip address 1.1.1.1/32
 ip ospf area 0
exit
!
! ============================ BGP (overlay control plane) ====================
! AS 1 for the whole data center: all sessions are iBGP (same AS).
router bgp 1
 bgp router-id 1.1.1.1
 !
 ! Peer-group "ibgp": one template shared by all leaves.
 !   remote-as 1         -> neighbors are in our AS (iBGP)
 !   update-source lo    -> sessions use our loopback 1.1.1.1 as source,
 !                          so they survive a link failure while OSPF reroutes
 neighbor ibgp peer-group
 neighbor ibgp remote-as 1
 neighbor ibgp update-source lo
 !
 ! Dynamic neighbors: accept a session from any address in 1.1.1.0/29
 ! (1.1.1.0 - 1.1.1.7). Leaves are added without listing each one here.
 bgp listen range 1.1.1.0/29 peer-group ibgp
 !
 ! EVPN address family (MP-BGP): carries VTEPs (type 3) and MACs (type 2).
 !   activate                -> exchange EVPN routes with the leaves
 !   route-reflector-client  -> iBGP normally forbids passing a route learned
 !                              from one iBGP peer to another. Clients are the
 !                              exception: the RR reflects their routes to all.
 address-family l2vpn evpn
  neighbor ibgp activate
  neighbor ibgp route-reflector-client
 exit-address-family
exit
!
end
! Save the running configuration to /etc/frr/frr.conf
write memory
VTY
