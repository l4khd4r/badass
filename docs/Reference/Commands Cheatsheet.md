---
tags: [reference, commands]
---

# Commands cheatsheet

← [[00 Home]]

## Build & deploy (on your machine)

```sh
./P1/image_builder.sh                       # build host_mlakhdar:p1 + router_mlakhdar:p1
docker images | grep mlakhdar
docker ps --format '{{.Names}}' | grep GNS3 # see GNS3 containers
./P2/deploy.sh static | multicast
./P3/deploy.sh routers | hosts-noip | hosts | all
docker exec -it GNS3.router-mlakhdar-2.<id> bash   # shell without the GNS3 console
```

## Linux — interfaces & addresses

```sh
ip a                          # all interfaces + addresses
ip -4 addr                    # IPv4 only
ip -d link show vxlan10       # -d = details: VNI, local, remote/group, port, nolearning
ip link set eth0 up
ip addr replace 10.1.1.1/24 dev eth0
ip addr flush dev eth0
ip route                      # kernel routing table (FIB)
ip neigh                      # ARP cache
ip neigh flush all
```

## Linux — bridge & VXLAN

```sh
bridge link                           # ports, master, state
bridge fdb show br br0                # bridge MAC table
bridge fdb show dev vxlan10           # VXLAN table: MAC → remote VTEP
brctl show                            # legacy
```

## Capture

```sh
tcpdump -ni eth0                      # everything on eth0
tcpdump -ni eth0 udp port 4789        # VXLAN only
tcpdump -ni eth0 proto ospf
tcpdump -ni eth0 tcp port 179         # BGP
tcpdump -ni eth1 arp
```

Wireshark filters: `vxlan`, `ospf`, `bgp`, `arp`, `icmp`, `vxlan.vni == 10`.

## FRR (vtysh)

```sh
vtysh -c "show daemons"
vtysh -c "show running-config"
vtysh -c "show interface brief"
```

### OSPF
```sh
vtysh -c "show ip ospf neighbor"
vtysh -c "show ip ospf interface"
vtysh -c "show ip ospf database"
vtysh -c "show ip route"
vtysh -c "show ip route ospf"
```

### BGP
```sh
vtysh -c "show bgp summary"
vtysh -c "show bgp l2vpn evpn summary"
vtysh -c "show bgp neighbors 1.1.1.1"
```

### EVPN
```sh
vtysh -c "show bgp l2vpn evpn"                 # all routes (type 2 + 3)
vtysh -c "show bgp l2vpn evpn route type macip"
vtysh -c "show bgp l2vpn evpn route type multicast"
vtysh -c "show bgp l2vpn evpn vni"
vtysh -c "show evpn vni"                       # VNIs known to zebra
vtysh -c "show evpn vni 10"                    # remote VTEPs
vtysh -c "show evpn mac vni 10"                # local/remote MACs
```

## Host tests

```sh
ping -c 4 30.1.1.2              # P2
ping -c 3 20.1.1.2              # P3
ping -c 2 -I 1.1.1.2 1.1.1.3    # P3 router: loopback to loopback
ping -s 1472 -M do 20.1.1.2     # MTU test (don't fragment)
```
