#!/bin/bash

echo  "stopping nextdns..."
sudo nextdns deactivate
sudo nextdns stop

sudo nextdns status
