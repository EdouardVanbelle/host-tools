#!/bin/bash

# example (only tested with a MFC-L3750CDW, firmware N 1.58)
# $ ./get_printer_level.sh


# XXX: requirement nedd curl and avahi-brose

# Brother Brother\032MFC-L3750CDW\032series (BRN3C?????????.local) found
#
# ok: Drum Unit Cyan=98
# ok: Drum Unit Magenta=98
# ok: Drum Unit Yellow=98
# ok: Drum Unit Black=98
# ok: Belt Unit=99
# ok: Fuser Unit=99
# ok: PF Kit 1=100
# ok: Toner Cyan=60
# ok: Toner Magenta=60
# ok: Toner Yellow=60
# warn: Toner Black=50


# arbitrary level
THRESHOLD=5

# TODO: trigger alarm

# -----------------------------------------------------------


query_brother() {

       PRINTER="$1"
       exec 5< <(curl -s "http://$PRINTER/etc/mnt_info.csv")

       COUNT=0
       while read -r LINE <&5
       do
               if [ $COUNT -eq 0 ]
               then
                       HEADERLINE="$LINE"
               else
                       VALUELINE="$LINE"
               fi
               ((COUNT++))
       done
       # close FD
       exec 5<&-

       exec 6< <(echo "$HEADERLINE" | sed 's/","/\n/g; s/^"//; s/",$//; ')
       exec 7< <(echo "$VALUELINE"  | sed 's/","/\n/g; s/^"//; s/",$//; ')

       MATCH=0

       while read -r KEY <&6
       do
               read -r VALUE <&7
               #DEBUG echo "$KEY:$VALUE"

               # FIXME: may change according model / firmware version

               #case $KEY in
               #       "% of Life Remaining(Toner Cyan)")    C=$VALUE ;;
               #       "% of Life Remaining(Toner Magenta)") M=$VALUE ;;
               #       "% of Life Remaining(Toner Yellow)")  Y=$VALUE ;;
               #       "% of Life Remaining(Toner Black)")   K=$VALUE ;;
               #esac

               case "$KEY" in
                       "Model Name")
                               echo $KEY $VALUE
                               [[ "$VALUE" == "Brother"* ]] && MATCH=1
                               ;;
                       "% of Life Remaining"*)
                               KEY=${KEY#"% of Life Remaining("}
                               KEY=${KEY%")"}

                               # remove possible .XX
                               VALUE=${VALUE%.*}

                               if [ $VALUE -le $THRESHOLD ]
                               then
                                       #alarm
                                       echo "warn: $KEY=$VALUE"
                               else
                                       echo "ok: $KEY=$VALUE"

                               fi
                               ;;

               esac
       done

       exec 6<&-
       exec 7<&-

       if [ $MATCH -eq 0 ]
       then
               echo "Printer does not seem to be a Brother"
       fi
       #echo "C=$C Y=$Y M=$M K=$K"
}


while IFS=";" read -r MATCH IFACE PROTO NAME SERVICE DOMAIN FQDN IP PORT TXT
do
       [ "$MATCH" != "="    ] && continue
       [ "$PROTO" != "IPv4" ] && continue

       #DEBUG echo $MATCH $IFACE $PROTO $NAME $SERVICE $DOMAIN $FQDN $IP $PORT $TXT

       case "$NAME" in
               "Brother"*)
                       echo "Brother $NAME ($FQDN) found"
                       echo
                       query_brother $IP
                       echo
                       ;;

               *)
                       echo "printer $NAME unknown ($FQDN - $IP) $TXT"
                       ;;
       esac

       #echo querying $PRINTER
done < <(avahi-browse --ignore-local --resolve --terminate --no-db-lookup --parsable _printer._tcp)

