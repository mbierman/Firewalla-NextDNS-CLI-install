#!/bin/bash
  
# install & configure NextDNS CLI on startup of Firewalla
# file goes in: /home/pi/.firewalla/config/post_main.d/
# DNS over HTTPS must be disabled in Firewalla app
# Based on Brian Curtis' script https://help.firewalla.com/hc/en-us/community/posts/7469669689619-NextDNS-CLI-on-Firewalla-revisited-working-DHCP-host-resolution-in-NextDNS-logs-

# install NextDNS CLI
sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg
echo "deb [signed-by=/usr/share/keyrings/nextdns.gpg] https://repo.nextdns.io/deb stable main" | sudo tee /etc/apt/sources.list.d/nextdns.list
unalias apt
sudo apt update
sudo apt install nextdns

# replace -config 123456 with your own NextDNS config ID
# replace 10.10.12.1 with your Firewalla local lan IP
# enable NextDNS caching: https://github.com/nextdns/nextdns/wiki/Cache-Configuration
# set discovery-dns to IP of Firewalla local DNS
# set NextDNS CLI to listen on local network IP (instead of 127.0.0.1 -- allows DHCP host resolution in NextDNS logs)
# define listen port instead of relying on -setup-router
id=123456
IP=10.10.12.1
sudo nextdns install -config $id -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns $IP -listen ${IP}:5555

# alternate command to implement conditional configuration: https://github.com/nextdns/nextdns/wiki/Conditional-Configuration
# replace 192.168.122.0/24=abcdef with your own additional network and NextDNS config ID
# sudo nextdns install -config 192.168.122.0/24=abcdef -config 123456 -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns 10.10.12.1 -listen 10.10.12.1:5555

# Add dnsmasq integration to enable client reporting in NextDNS logs: https://github.com/nextdns/nextdns/wiki/DNSMasq-Integration
cat > /home/pi/.firewalla/config/dnsmasq/mynextdns.conf << EOF
server=${IP}#5555
add-mac
add-subnet=32,128
EOF

# restart Firewalla DNS service
sudo systemctl restart firerouter_dns.service

echo nextdns is... $(sudo nextdns status)
