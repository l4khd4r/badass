# P2 — Discovering a VXLAN

Two hosts on the **same LAN (30.1.1.0/24)**, behind two different routers, connected
through a **VXLAN tunnel (VNI 10)** over an IP network (10.1.1.0/24).

The same setup is built in two modes:

| Mode | How a VTEP sends broadcast / unknown traffic (BUM) |
|---|---|
| **static** | to one fixed peer (`remote <other VTEP>`) |
| **multicast** | to a multicast group (`group 239.1.1.1`) that every VTEP joins |

---

## Topology

```text
host-mlakhdar-1                router-mlakhdar-1                router-mlakhdar-2                host-mlakhdar-2
  30.1.1.1/24                       (VTEP)                           (VTEP)                        30.1.1.2/24
     eth0 ─────────────── eth1 ─┐                                            ┌─ eth1 ─────────────── eth0
                                br0 ── vxlan10 ════ VNI 10 ════ vxlan10 ── br0
                           eth0: 10.1.1.1/24 ──────── Switch1 ──────── eth0: 10.1.1.2/24
```

### Underlay vs overlay

| | Underlay | Overlay |
|---|---|---|
| What | real network between the routers | virtual LAN between the hosts |
| Addresses | 10.1.1.0/24 | 30.1.1.0/24 |
| In a packet | outer IP + UDP 4789 + VXLAN header | inner Ethernet + IP + ICMP |

The switch only sees 10.1.1.x. The hosts only see 30.1.1.x.

### IP plan

| Node | Interface | Address | Role |
|---|---|---|---|
| router-mlakhdar-1 | eth0 | 10.1.1.1/24 | underlay, towards Switch1 |
| router-mlakhdar-1 | eth1 | — | bridge port to host-mlakhdar-1 |
| router-mlakhdar-2 | eth0 | 10.1.1.2/24 | underlay, towards Switch1 |
| router-mlakhdar-2 | eth1 | — | bridge port to host-mlakhdar-2 |
| host-mlakhdar-1 | eth0 | 30.1.1.1/24 | overlay |
| host-mlakhdar-2 | eth0 | 30.1.1.2/24 | overlay |

The routers' `eth1` has **no IP**: it is a switch port inside `br0`.

---

## Files

| File | Role |
|---|---|
| `P2.gns3project` | GNS3 portable export of the topology |
| `deploy.sh` | copies each node's script into its container and runs it |
| `scripts/router-mlakhdar-1.sh` | VTEP 1: underlay IP, `vxlan10`, `br0` (`static` or `multicast`) |
| `scripts/router-mlakhdar-2.sh` | VTEP 2: same, mirrored addresses |
| `scripts/host-mlakhdar-1.sh` | host 1: 30.1.1.1/24 on eth0 |
| `scripts/host-mlakhdar-2.sh` | host 2: 30.1.1.2/24 on eth0 |

The Docker images from P1 are reused unchanged. **No configuration is baked into the
images**: all addresses come from these scripts.

---

## Run

1. Build the P1 images if needed: `./P1/image_builder.sh`
2. In GNS3: **File → Import portable project** → `P2/P2.gns3project`, then **Start** all nodes.
3. Apply a mode:

```sh
cd P2
./deploy.sh static       # or: ./deploy.sh multicast
```

GNS3 Docker nodes lose their network config when they restart, so run `deploy.sh`
again after any restart. Running it again also switches between modes.

---

## What the router script does

```sh
ip addr replace 10.1.1.1/24 dev eth0      # underlay address (connected route 10.1.1.0/24)
ip link set eth0 up

ip link del vxlan10                       # remove an old tunnel, if any

# static: one fixed peer
ip link add vxlan10 type vxlan id 10 local 10.1.1.1 remote 10.1.1.2 dstport 4789 dev eth0
# multicast: BUM traffic goes to the group, joined on eth0
ip link add vxlan10 type vxlan id 10 group 239.1.1.1 local 10.1.1.1 dstport 4789 dev eth0

ip link add br0 type bridge               # software switch
ip link set eth1 master br0               # host port into the switch
ip link set vxlan10 master br0            # tunnel into the switch
ip link set eth1 up; ip link set vxlan10 up; ip link set br0 up
```

| Option | Meaning |
|---|---|
| `id 10` | VNI 10, the segment number carried in every VXLAN header |
| `local` | source IP of the outer packet (this VTEP) |
| `remote` | destination IP of the outer packet (static mode only) |
| `group 239.1.1.1` | multicast group for BUM traffic (multicast mode only) |
| `dstport 4789` | standard VXLAN UDP port (Linux defaults to 8472 otherwise) |
| `dev eth0` | underlay interface used to send the outer packets |

---

## Verify

**Underlay** (from a router):
```sh
ping -c 2 10.1.1.2
```

**Overlay** (from host-mlakhdar-1):
```sh
ping -c 4 30.1.1.2
```
`ttl=64` in the replies: no router between the hosts, they share one LAN.

**Tunnel mode** (from a router):
```sh
ip -d link show vxlan10       # "remote 10.1.1.2" (static) or "group 239.1.1.1" (multicast)
```

**Learned MAC addresses** (from a router):
```sh
bridge fdb show br br0 | grep vxlan10
```

| Entry | Meaning |
|---|---|
| `<host2 MAC> dev vxlan10 master br0` | bridge: host2 is behind the tunnel port |
| `<host2 MAC> dev vxlan10 dst 10.1.1.2 self` | tunnel: send it to router-mlakhdar-2 |
| `00:00:00:00:00:00 dev vxlan10 dst 239.1.1.1 via eth0` | multicast: unknown / broadcast frames go to the group |
| `00:00:00:00:00:00 dev vxlan10 dst 10.1.1.2` | static: unknown / broadcast frames go to the peer |

**Wireshark** (capture a router ↔ Switch1 link, filter `vxlan`):
- outer: `10.1.1.1 ↔ 10.1.1.2`, UDP 4789, VXLAN **VNI 10**
- inner: `30.1.1.1 ↔ 30.1.1.2`, ICMP
- frame size 148 bytes vs 98 for a plain ping: **50 bytes** of VXLAN encapsulation
- multicast mode: the first ARP request goes to **239.1.1.1**, then the pings go directly to 10.1.1.x
  (clear the host's ARP cache first with `ip neigh flush all` to see it)

---

## Flood and learn

1. host1 sends an ARP broadcast: "who has 30.1.1.2?"
2. router1 does not know where it goes: it sends it to the peer (static) or to the group (multicast).
3. router2 decapsulates it and delivers it to host2.
4. host2 replies; router1 learns `host2 MAC → 10.1.1.2`.
5. Every next frame to host2 goes directly to router2.

The VTEPs learn MACs by watching traffic, like a normal switch. P3 replaces this
flooding with **BGP EVPN**, which announces VTEPs and MACs explicitly.

---

## Troubleshooting

| Symptom | Check |
|---|---|
| `Destination Host Unreachable` | the other host has its IP? (`ip a`) |
| `NO-CARRIER` on an interface | wrong port cabled in GNS3: hover the link to see its ports |
| ping fails, underlay OK | `bridge link` on each router: `eth1` and `vxlan10` in `br0`, `forwarding` |
| replies leave the wrong interface | `ip route` on the host: only one route for 30.1.1.0/24 |
| no traffic at all | same VNI and port (10 / 4789) on both routers: `ip -d link show vxlan10` |



## Resources 
https://ipwithease.com/difference-between-underlay-network-and-overlay-network/

https://ipwithease.com/vteps-and-vnis-in-vxlan/