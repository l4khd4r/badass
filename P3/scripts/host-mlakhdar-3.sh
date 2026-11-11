#!/bin/sh
# =============================================================================
# P3 - host-mlakhdar-3 (behind router-mlakhdar-4, on its port eth0)
#
# The host lives in the overlay LAN 20.1.1.0/24 (VNI 10). It does not know
# about VXLAN or BGP: for it, the other hosts are on the same Ethernet LAN.
#
# Usage:
#   sh host-mlakhdar-3.sh         -> port up + IP 20.1.1.3/24
#   sh host-mlakhdar-3.sh noip    -> port up only, no IP
#
# "noip" reproduces the subject's test: as soon as the host sends any frame
# (Linux sends IPv6 messages automatically when a port comes up), its leaf
# sees its MAC on br0 and announces it as an EVPN type 2 route, even though
# the host has no IP address yet.
# =============================================================================

# Remove any old address so the script can run twice without errors
ip addr flush dev eth0 2>/dev/null

# Bring the port up: from now on the leaf can see this host's MAC
ip link set eth0 up

# In "noip" mode, stop here (no IP address)
[ "$1" = "noip" ] && exit 0

# Overlay address: same subnet on every host, so no gateway is needed.
# They reach each other directly, through VXLAN, as if on one switch.
ip addr add 20.1.1.3/24 dev eth0
ip addr show dev eth0
