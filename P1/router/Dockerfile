# BADASS P1 - ROUTER image
FROM alpine:3.23


# Install FRRouting and network troubleshooting tools

RUN apk add --no-cache \
    bash \
    frr \
    iproute2 \
    iputils \
    tcpdump \
    bridge-utils

# Enable the routing daemons required by the project.

COPY daemons /etc/frr/daemons

COPY start-router.sh /usr/local/bin/start-router

# Single integrated config: frr.conf (no IP) + vtysh.conf (vtysh saves into frr.conf)
COPY frr.conf vtysh.conf /etc/frr/

# FRR daemons run as user frr: it must own its config and its PID/socket dir
RUN chmod +x /usr/local/bin/start-router \
    && mkdir -p /run/frr \
    && chown -R frr:frr /etc/frr /run/frr \
    && chmod 640 /etc/frr/frr.conf
# Start FRR services, then provide an interactive shell for troubleshooting.


CMD ["/usr/local/bin/start-router"]


