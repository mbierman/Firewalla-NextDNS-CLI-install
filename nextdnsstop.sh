#!/bin/bash
period=4

echo  "stopping nextdns..."
sudo nextdns deactivate && sleep $period
sudo nextdns stop && sleep $period
sudo nextdns status

touch /data/stopnextdns
echo created /data/stopnextdns remove this file to restart nextdns
/data/flushdns.sh
