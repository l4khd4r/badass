#!/bin/sh 
# P2 - router-mlakhdar-2.sh
# Usage : sh router-mlakhdar-2.sh static | multicast

MODE=${1:-static}

# Underlay: address on the link to the switch (connected route 10.1.1.0/24)
ip addr replace 10.1.1.2/24 dev eth0 
ip link set eth0 up


# Remove an old tunnel if it exists (example: script run twice)
ip link del vxlan10 2>/dev/null


# Overlay: VXLAN tunnel, VNI 10, standard UDP port 4789

if [ "$MODE" = "multicast" ]; then
    # BUM traffic goes to multicast group 239.1.1.1, joined on eth0
    ip link add vxlan10 type vxlan id 10 group 239.1.1.1 local 10.1.1.2 dstport 4789 dev eth0 
else
    # BUM traffic goes to unicast address
    ip link add vxlan10 type vxlan id 10  local 10.1.1.2 remote 10.1.1.1 dstport 4789 dev eth0
fi

# Bridge br0: software switch joining the host port and the tunnel

ip link add br0 type bridge 2>/dev/null
ip link set eth1 master br0
ip link set vxlan10 master br0

ip link set eth1 up
ip link set vxlan10 up
ip link set br0 up
