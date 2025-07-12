#!/bin/bash
version=2.0
period=4
dnsmasq=/home/pi/.firewalla/config/dnsmasq_local/nextdns

set -euo pipefail

command -v nextdns >/dev/null || { echo "nextdns not found"; exit 1; }
echo  "stopping nextdns..."
sudo nextdns deactivate && sleep $period
sudo nextdns stop && sleep $period
sudo nextdns status

if ! touch "$dnsmasq" 2>/dev/null; then
  echo "Cannot write to $dnsmasq"
  exit 1
fi

cat > "$dnsmasq" << 'EOF'
# server=${IP}#5555
# add-mac
# add-subnet=32,128
EOF

sudo systemctl stop firerouter_dns && sleep 5 && sudo systemctl start firerouter_dns


touch /data/stopnextdns
echo created /data/stopnextdns remove this file to restart nextdns
/data/flushdns.sh
