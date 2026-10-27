# BADASS

**BGP At Doors of Autonomous Systems is Simple**

A network administration project implemented with Docker and GNS3.

## Project objectives

- Build reusable Docker images for hosts and routers.
- Create and document a reproducible GNS3 topology.
- Configure VXLAN with VNI 10 using static and multicast modes.
- Implement BGP EVPN without MPLS, using an OSPF underlay.
- Demonstrate EVPN route types 2 and 3 and MAC learning.

## Project structure

```text
badass/
├── docs/
├── P1/
│   ├── host/
│   ├── router/
│   └── configs/
├── P2/
│   └── configs/
└── P3/
    └── configs/
