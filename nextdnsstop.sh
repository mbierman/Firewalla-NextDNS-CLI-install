#!/bin/bash
period=4

echo  "stopping nextdns..."
sudo nextdns deactivate && sleep $period
sudo nextdns stop && sleep $period

cat > $dnsmasq << EOF
# server=${IP}#5555
# add-mac
# add-subnet=32,128
EOF

sudo systemctl stop firerouter_dns && sleep 5 && ssudo systemctl start firerouter_dns

touch /data/stopnextdns
echo created /data/stopnextdns remove this file to restart nextdns
/data/flushdns.sh
sudo nextdns status
