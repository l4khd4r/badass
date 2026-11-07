#!/bin/sh
# =============================================================================
# P2 - host-mlakhdar-1
# Puts the host in the overlay LAN 30.1.1.0/24 (VNI 10).
# Same script for static and multicast mode: the host never sees the tunnel.
# Usage: sh host-mlakhdar-1.sh
# =============================================================================
 

# Remove any old address so the script can run twice without error

ip addr flush dev eth0 2>/dev/null

# Overlay address : same subnet as host-mlakhdar-2, so no gateway is needed 

ip addr add 30.1.1.1/24 dev eth0 

# Turn the interface up 
ip link set eth0 up

# Show the result
ip addr show dev eth0 
