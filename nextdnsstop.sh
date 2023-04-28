#!/bin/bash

echo  "stopping nextdns..."
sudo nextdns deactivate
sudo nextdns stop

sudo nextdns status
touch /data/stopnextdns
echo created /data/stopnextdns remove this file to restart nextdns
