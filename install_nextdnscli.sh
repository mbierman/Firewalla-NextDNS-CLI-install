#!/bin/bash

# 2.1.1
# Based on a script by Brian Curtis 
# https://help.firewalla.com/hc/en-us/community/posts/7469669689619-NextDNS-CLI-on-Firewalla-revisited-working-DHCP-host-resolution-in-NextDNS-logs-

# install & configure NextDNS CLI on startup of Firewalla
# file goes in: /home/pi/.firewalla/config/post_main.d/
# DNS over HTTPS must be disabled in Firewalla app

# set id with your own NextDNS config ID
# set IP with your Firewalla local lan IP
id=42eadb
IP=192.168.0.1
VPNID=f1273e
OpenVPN=10.128.98.1
WireGuard=10.189.55.1
appletvid=7c6a43

install=/home/pi/.firewalla/config/post_main.d/install_nextdnscli.sh 

if [ -f /data/stopnextdns ] ; then
        echo "❌  No nextDNS" 
        exit
fi

DIR="/home/pi/.firewalla/config/post_main.d"
if [ ! -d  $DIR ]; then
	mkdir /home/pi/.firewalla/config/post_main.d 
fi

# Install validation Script if not installed. 
nextdnstest=/data/nextdnstest.sh
if [ ! -f "$nextdnstest" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/nextdnstest.sh > $nextdnstest
        chmod +x $nextdnstest
        echo "✅  test saved."
else
        echo "✅  test in place."
fi

# Install data for IFTTT notification
nextdnsdata=/data/nextdnsdata.txt
if [ ! -f "$nextdnsdata" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/nextdnsdata.txt > $nextdnsdata
        chmod +x $nextdnsdata
        echo "✅  data saved."
else
        echo "✅  data in place."
fi


# check for configuration
if [[ -z $id ]] ; then
        echo -e "Your nextdns ID is not set.\nEdit using your favorite editor (vi is already installed on Firewalla) run $install and run."
        exit
elif [[ -z $IP ]] ; then
        echo -e "Your Firewalla IP is not set.\nEdit using your favorite editor (vi is already installed on Firewalla) and run $install ."
        exit
else
        echo -e "Fully configured and ready to go!\n\n"
fi

# Install script if not installed. 
if [ ! -f "$install" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh > $install
        chmod +x $install
        echo "✅  install saved."
else
        echo "✅  install in place. "
fi

# Install Uninstall script if not installed
uninstall=/home/pi/.firewalla/config/post_main.d/uninstall_nextdnscli.nosh 
if [ ! -f "$uninstall" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/uninstall_nextdns_cli.nosh > $uninstall
        chmod +x $uninstall
        echo "✅  uninstall saved."
else
        echo "✅  uninstall in place.."
fi
# install NextDNS CLI
if [ -z "$(command -v nextdns)" ] ; then
        unalias apt
	sudo apt install ca-certificates
	sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg
	echo "deb [signed-by=/usr/share/keyrings/nextdns.gpg] https://repo.nextdns.io/deb stable main" | sudo tee /etc/apt/sources.list.d/nextdns.list
	sudo apt update
	sudo apt install nextdns
else
	echo "✅  nextdns already installed..."
fi

cat > /home/pi/.firewalla/config/dnsmasq/mynextdns.conf << EOF
server=${IP}#5555
add-mac
add-subnet=32,128
EOF

echo -e "\nStarting nextdns...\n\n"

sudo nextdns install \
-config C8:D0:83:E3:2C:21=$appletvid \
-config C8:D0:83:D7:7A:6E=$appletvid \
-config C8:D0:83:DD:09:2C=$appletvid \
-config ${IP}/24=${id} \
-config $OpenVPN/24=$VPNID \
-config $WireGuard/24=$VPNID \
-report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns ${IP} -listen ${IP}:5555 

# enable NextDNS caching: https://github.com/nextdns/nextdns/wiki/Cache-Configuration
# set discovery-dns to IP of Firewalla local DNS
# set NextDNS CLI to listen on local network IP (instead of 127.0.0.1 -- allows DHCP host resolution in NextDNS logs)
# define listen port instead of relying on -setup-router
# sudo nextdns install -config $id -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns $IP/24 -listen ${IP}:5555
# You can also put a config for an individual mac address like so. 
# -config xx:yy:zz:aa:bb:cc=${id} \


# Add dnsmasq integration to enable client reporting in NextDNS logs: https://github.com/nextdns/nextdns/wiki/DNSMasq-Integration

# sudo nextdns restart 
echo "Restarting Firewalla DNS..." 
sudo systemctl restart firerouter_dns.service && echo "nextdns is... $(sudo nextdns status)"
