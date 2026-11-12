---
tags: [concept, l3]
aliases: [Loopback, lo]
---

# Loopback interface

← [[Concept Map]]

A **virtual interface** (`lo`) with no cable. It's **always up** as long as the router is alive.

On routers you give it a **/32** address (1.1.1.x) and advertise it in the IGP. Then:

| Used as | Why a loopback |
|---|---|
| **OSPF router-id** / **BGP router-id** | stable, unique, readable name |
| **BGP session source** (`update-source lo`) | if one physical link fails and another path exists, the session survives: OSPF reroutes, the loopback stays reachable. A session bound to a link IP dies with the link |
| **VTEP address** (`local 1.1.1.2`) | same stability for the tunnels; independent of which uplink is used |

> [!warning] A loopback is only useful if it's **advertised**
> That's why every P3 router has `interface lo / ip ospf area 0`. Without it, nobody could
> reach 1.1.1.x → no BGP sessions, no VXLAN.

Test from a loopback: `ping -I 1.1.1.2 1.1.1.3` — forces the source address.

Related: [[OSPF]] · [[BGP]] · [[VTEP]]
