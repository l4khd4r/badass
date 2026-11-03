#!/bin/bash
# start-router.sh: start the FRR daemons enabled in /etc/frr/daemons, then keep a shell

# The mkdir/chown of /run/frr moved into the Dockerfile; you can delete those two lines here

# frrcommon.sh reads /etc/frr/daemons; daemon_list returns the enabled daemons + zebra/mgmtd/staticd
source /usr/lib/frr/frrcommon.sh
/usr/lib/frr/watchfrr -d $(daemon_list)   # CHANGE: was "-F traditional zebra bgpd ospfd isisd staticd"

exec /bin/bash -i