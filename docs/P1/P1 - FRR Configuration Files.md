---
tags: [badass, p1, frr, config]
---

# P1 — FRR configuration files

← [[P1 - Router Image]] · See also [[FRRouting]]

Three small files copied into `/etc/frr/` of the router image.

## `daemons`

```ini
zebra=yes      # core manager, installs routes into the kernel
bgpd=yes       # BGP: used in P3 (EVPN + route reflector)
ospfd=yes      # OSPF: P3 underlay
isisd=yes      # IS-IS: required by the subject

ospf6d=no
ripd=no
... (all others = no)

vtysh_enable=yes
```

- Each `xxxd=yes` line enables a daemon; `start-router.sh` reads this through `daemon_list`.
- Only what the subject needs is enabled → less memory, smaller attack surface, clearer `ps`.
- **IS-IS** is enabled but never configured: the subject requires the daemon to be present. IS-IS is another link-state protocol (like [[OSPF]]), very common as a data-center underlay.
- `vtysh_enable=yes`: allow the unified shell `vtysh`.

## `frr.conf`

```text
! Base FRR config. No IP address on purpose (subject requirement).
frr defaults traditional
log stdout
!
line vty
```

| Line | Meaning |
|---|---|
| `!` | comment |
| `frr defaults traditional` | Use "traditional" defaults (classic router behaviour) rather than the `datacenter` profile (which changes timers and some BGP defaults). Example: with `traditional`, a BGP neighbor is activated in IPv4 unicast automatically — that's why in P3 `show bgp summary` shows the RR both in **IPv4 Unicast** and **L2VPN EVPN** |
| `log stdout` | Daemon logs go to the console |
| `line vty` | Section for the virtual terminal (empty) |

There is **no `interface ... ip address`** here. In P3 the scripts add everything via `vtysh` and `write memory`, which rewrites this file.

## `vtysh.conf`

```text
service integrated-vtysh-config
```

Without this, each daemon has its own file (`zebra.conf`, `bgpd.conf`, `ospfd.conf`…).
With it, `write memory` from `vtysh` saves **everything into one `/etc/frr/frr.conf`**. One file = easier to read and to check during the evaluation (`show running-config`).

## vtysh in one minute

`vtysh` is a Cisco-like CLI that talks to all the daemons at once.

```sh
vtysh                                    # interactive
vtysh -c "show ip route"                 # one command
vtysh <<'EOF'                            # a whole config block (used by P3 scripts)
configure terminal
router ospf
 ospf router-id 1.1.1.2
end
write memory
EOF
```

| Mode | Prompt | Enter with |
|---|---|---|
| exec | `router#` | (default) |
| config | `router(config)#` | `configure terminal` |
| sub-config | `router(config-router)#` | `router ospf`, `router bgp 1`, `interface eth0`… |
| leave | | `exit` (one level) / `end` (all the way) |
