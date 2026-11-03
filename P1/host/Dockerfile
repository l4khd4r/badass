# BADASS  P1 - HOST image

# Alpine provides a minimal Linux userspace with BusyBox.

FROM alpine:3.23

# Install dependencies
RUN apk add --no-cache \
    iproute2 \
    iputils \
    tcpdump \
    net-tools 


# Start an interactive shell
# No static  IP address
CMD ["/bin/sh"]
