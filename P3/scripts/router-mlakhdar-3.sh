#!/bin/sh
# =============================================================================
# P3 - router-mlakhdar-3 : LEAF / VTEP
#
# Role in the fabric:
#   - Underlay : one /30 link to the route reflector (router-mlakhdar-1).
#                OSPF advertises this link and the loopback 1.1.1.3, and
#                learns the routes to every other loopback through the RR.
#   - Overlay  : ONE iBGP session (AS 1) to the RR's loopback 1.1.1.1.
#                EVPN announces:
#                  type 3 -> "I am a VTEP for VNI 10, at 1.1.1.3"
#                  type 2 -> "this MAC is behind me" (one per host MAC)
#   - Data     : Linux VXLAN interface vxlan10 (VNI 10) + bridge br0 that
#                joins it with the host port. Same idea as P2, but the peers
#                and the MACs now come from BGP instead of flood-and-learn.
#
# Interfaces:   eth1 -> router-mlakhdar-1 (RR)   10.1.1.6/30   (RR side: 10.1.1.5)
#               eth0 -> host-mlakhdar-2       no IP: bridge port inside br0
#               lo   -> loopback                  1.1.1.3/32
# =============================================================================

# ---------------------------- FRR configuration ------------------------------
vtysh <<'VTY'
configure terminal
hostname router-mlakhdar-3
!
! ============================ OSPF (underlay) ================================
! router-id = loopback address: unique name of this router in the OSPF map.
! Two routers with the same router-id would break OSPF.
router ospf
 ospf router-id 1.1.1.3
exit
!
! ============================ Interfaces =====================================
! Uplink to the RR: /30 point-to-point link, in OSPF area 0 (backbone).
! OSPF forms an adjacency with the RR on this link (state "Full").
interface eth1
 ip address 10.1.1.6/30
 ip ospf area 0
exit
!
! Loopback: stable identity. Used as BGP source and as the VTEP address
! (outer source IP of the VXLAN packets). Advertised in OSPF so that the RR
! and the other leaves can reach it.
interface lo
 ip address 1.1.1.3/32
 ip ospf area 0
exit
!
! The host port (eth0) gets NO IP and is NOT in OSPF: it belongs to the
! overlay, it is configured below as a port of the Linux bridge br0.
!
! ============================ BGP (overlay control plane) ====================
router bgp 1
 bgp router-id 1.1.1.3
 !
 ! Only one neighbor: the route reflector, reached through OSPF.
 !   remote-as 1       -> same AS: iBGP
 !   update-source lo  -> open the session from our loopback 1.1.1.3
 neighbor 1.1.1.1 remote-as 1
 neighbor 1.1.1.1 update-source lo
 !
 ! EVPN address family:
 !   activate           -> exchange EVPN routes with the RR
 !   advertise-all-vni  -> FRR finds every VXLAN interface in a bridge (here
 !                         vxlan10, VNI 10) and announces it: a type 3 route
 !                         right away, then a type 2 route for each MAC that
 !                         appears on br0. Routes received from the RR fill
 !                         the VTEP list and the remote MACs of vxlan10.
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
 exit-address-family
exit
!
end
! Save the running configuration to /etc/frr/frr.conf
write memory
VTY

# ---------------------------- Linux data plane -------------------------------
# Remove an old tunnel if the script is run twice
ip link del vxlan10 2>/dev/null

# VXLAN interface:
#   id 10            -> VNI 10, written in the VXLAN header of every packet
#   local 1.1.1.3    -> outer source IP = our loopback
#   dstport 4789     -> standard VXLAN UDP port
#   nolearning       -> do not learn remote MACs from traffic: BGP EVPN
#                       (type 2 routes) installs them instead
# No "remote" and no "group" (unlike P2): the list of remote VTEPs comes from
# the type 3 routes received over BGP.
ip link add vxlan10 type vxlan id 10 local 1.1.1.3 dstport 4789 nolearning

# Bridge br0: software switch with two ports
#   eth0     -> the host
#   vxlan10  -> the tunnel to the other leaves
ip link add br0 type bridge 2>/dev/null
ip link set eth0 master br0
ip link set vxlan10 master br0

# Turn everything on
ip link set eth0 up
ip link set vxlan10 up
ip link set br0 up
