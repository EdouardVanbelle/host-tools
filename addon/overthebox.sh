#!/bin/bash

ECODE=0

# exit code:
# 0 ok
# 1 warn
# 2 crit

# XXX: must have a root access to overthebox.lan
# for that purpose install your publix key into /etc/dropbear/authorized_keys

while read -r INTERFACE DEVICE STATUS PUBLIC_IP LATENCY
do

       # ignore header
       [ "$INTERFACE" == "INTERFACE" ] && continue

       #keep only wan* interfaces
       [[ "$INTERFACE" =~ ^wan ]] || continue

       echo DEBUG: $INTERFACE $DEVICE $STATUS $PUBLIC_IP $LATENCY

       if [ "$STATUS" != "OK" ]
       then
               echo "$INTERFACE ($PUBLIC_IP) is down ($STATUS)" 1>&2
               ECODE=1
       fi

done < <( ssh root@overthebox.lan /bin/otb-status | grep -v -- '-----' | tr -d '|' | sed 's/^\s\+//')

exit $ECODE
