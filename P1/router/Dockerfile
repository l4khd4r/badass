# BADASS P1 - ROUTER image
FROM alpine:3.23


# Install FRRouting and network troubleshooting tools

RUN apk add --no-cache \
    bash \
    frr \
    iproute2 \
    iputils \
    tcpdump

# Enable the routing daemons required by the project.

COPY daemons /etc/frr/daemons

COPY start-router.sh /usr/local/bin/start-router

RUN chmod +x /usr/local/bin/start-router \
    && mkdir -p /etc/frr \
    && touch /etc/frr/frr.conf \
    /etc/frr/zebra.conf \
    /etc/frr/ospfd.conf \
    /etc/frr/bgpd.conf \
    /etc/frr/isisd.conf \
    && chown -R frr:frr /etc/frr \
    && chmod 640  /etc/frr/*.conf

# Start FRR services, then provide an interactive shell for troubleshooting.


CMD ["/usr/local/bin/start-router"]


