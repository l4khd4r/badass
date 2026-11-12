---
tags: [badass, p3, scripts]
---

# P3 — Script walkthrough

← [[P3 - Overview]]

## `deploy.sh`

```sh
WHAT=${1:-all}
ROUTERS="router-mlakhdar-1 router-mlakhdar-2 router-mlakhdar-3 router-mlakhdar-4"
HOSTS="host-mlakhdar-1 host-mlakhdar-2 host-mlakhdar-3"

case "$WHAT" in
    routers)    NODES=$ROUTERS ;;
    hosts)      NODES=$HOSTS ;;
    hosts-noip) NODES=$HOSTS; ARG=noip ;;
    all)        NODES="$ROUTERS $HOSTS" ;;
    *) echo "usage: ..."; exit 1 ;;
esac

for node in $NODES; do
    c=$(docker ps --format '{{.Names}}' | grep "^GNS3\.$node\." | head -1)
    [ -z "$c" ] && { echo "$node: not running, skipped"; continue; }

    # wait up to 20 s for GNS3 to plug the cables (eth0 exists)
    for i in $(seq 1 20); do
        docker exec "$c" ip link show eth0 >/dev/null 2>&1 && break
        sleep 1
    done
    ...
    docker cp "$DIR/$node.sh" "$c:/tmp/$node.sh" >/dev/null
    docker exec "$c" sh "/tmp/$node.sh" $ARG
done
```

Improvements over P2's deploy:
- **Modes** to reproduce the subject's demo in stages.
- **Waits for `eth0`**: right after ▶ Start, GNS3 creates the container first and plugs the virtual cables a moment later. Configuring before that would fail.
- No `-it` on `docker exec` → works from any shell, even non-interactive.
- `$ARG` unquoted on purpose: when empty, no argument is passed at all.

## Route reflector script (`router-mlakhdar-1.sh`)

Everything inside one `vtysh` heredoc:

```sh
vtysh <<'VTY'
configure terminal
hostname router-mlakhdar-1
router ospf
 ospf router-id 1.1.1.1
exit
interface eth0
 ip address 10.1.1.1/30
 ip ospf area 0
exit
interface eth1
 ip address 10.1.1.5/30
 ip ospf area 0
exit
interface eth2
 ip address 10.1.1.9/30
 ip ospf area 0
exit
interface lo
 ip address 1.1.1.1/32
 ip ospf area 0
exit
router bgp 1
 bgp router-id 1.1.1.1
 neighbor ibgp peer-group
 neighbor ibgp remote-as 1
 neighbor ibgp update-source lo
 bgp listen range 1.1.1.0/29 peer-group ibgp
 address-family l2vpn evpn
  neighbor ibgp activate
  neighbor ibgp route-reflector-client
 exit-address-family
exit
end
write memory
VTY
```

Points worth knowing:

- `<<'VTY'` — the **quoted** heredoc delimiter disables shell expansion inside, so `!` and `$` reach vtysh untouched.
- Lines starting with `!` are FRR comments.
- **IP addresses are set through FRR** (`interface eth0 / ip address ...`), not with `ip addr`. zebra pushes them into the kernel. Benefit: they appear in `show running-config` and are saved in `frr.conf`.
- `hostname` changes the vtysh prompt and the name in `show` outputs.
- `write memory` saves to `/etc/frr/frr.conf` (one file, thanks to `vtysh.conf`, see [[P1 - FRR Configuration Files]]).

Explained line by line: [[P3 - Underlay with OSPF]] and [[P3 - BGP and the Route Reflector]].

## Leaf script (`router-mlakhdar-2.sh`)

Two halves: **FRR** (control plane) then **Linux** (data plane).

### FRR half

```text
hostname router-mlakhdar-2
router ospf
 ospf router-id 1.1.1.2
interface eth0
 ip address 10.1.1.2/30
 ip ospf area 0
interface lo
 ip address 1.1.1.2/32
 ip ospf area 0
router bgp 1
 bgp router-id 1.1.1.2
 neighbor 1.1.1.1 remote-as 1
 neighbor 1.1.1.1 update-source lo
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
```

The host port (`eth1` on leaf 2) gets **no IP** and is **not** in OSPF.

### Linux half

```sh
ip link del vxlan10 2>/dev/null
ip link add vxlan10 type vxlan id 10 local 1.1.1.2 dstport 4789 nolearning
ip link add br0 type bridge 2>/dev/null
ip link set eth1 master br0
ip link set vxlan10 master br0
ip link set eth1 up
ip link set vxlan10 up
ip link set br0 up
```

| Option | Compared to P2 | Why |
|---|---|---|
| `id 10` | same | VNI 10 |
| `local 1.1.1.2` | was the link IP, now the **loopback** | stable; reachable via OSPF whatever link is used |
| *(no `remote`, no `group`)* | removed | the remote VTEP list comes from **type 3** routes |
| `dstport 4789` | same | standard port |
| `nolearning` | **new** | remote MACs come from **type 2** routes, not from traffic |
| *(no `dev eth0`)* | removed | not needed: no multicast; the kernel routes the outer packet with its routing table (via OSPF routes) |

> [!question] Order: FRR first, then the VXLAN device — is that OK?
> Yes. `advertise-all-vni` is a standing instruction: whenever zebra later sees a VXLAN
> interface attached to a bridge, bgpd starts advertising it. Configuring in the other
> order also works.

### Leaves 3 and 4

Same script; only these change:

| | leaf 2 | leaf 3 | leaf 4 |
|---|---|---|---|
| uplink | eth0 10.1.1.2/30 | eth1 10.1.1.6/30 | eth2 10.1.1.10/30 |
| loopback / router-id / `local` | 1.1.1.2 | 1.1.1.3 | 1.1.1.4 |
| host port in `br0` | eth1 | eth0 | eth0 |

## Host scripts

```sh
ip addr flush dev eth1 2>/dev/null     # idempotent
ip link set eth1 up                    # from now on the leaf can see this host's MAC
[ "$1" = "noip" ] && exit 0            # hosts-noip mode stops here
ip addr add 20.1.1.1/24 dev eth1
ip addr show dev eth1
```

| Host | Port | IP | Behind |
|---|---|---|---|
| host-mlakhdar-1 | eth1 | 20.1.1.1/24 | router-mlakhdar-2 |
| host-mlakhdar-2 | eth0 | 20.1.1.2/24 | router-mlakhdar-3 |
| host-mlakhdar-3 | eth0 | 20.1.1.3/24 | router-mlakhdar-4 |

`noip` mode exists purely to demonstrate that a **type 2 route appears before any IPv4 address** — see [[P3 - EVPN Route Types#When each route appears (the subject's demo)]].
