#!/bin/bash
# start-router.sh: start the FRR daemons enabled in /etc/frr/daemons, then keep a shell


# frrcommon.sh reads /etc/frr/daemons; daemon_list returns the enabled daemons + zebra/mgmtd/staticd
source /usr/lib/frr/frrcommon.sh
/usr/lib/frr/watchfrr -d $(daemon_list)  

exec /bin/bash -i