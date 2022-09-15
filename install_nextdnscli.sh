!/bin/bash

# 2.0.4
# Based on a script by Brian Curtis 
# https://help.firewalla.com/hc/en-us/community/posts/7469669689619-NextDNS-CLI-on-Firewalla-revisited-working-DHCP-host-resolution-in-NextDNS-logs-

# install & configure NextDNS CLI on startup of Firewalla
# file goes in: /home/pi/.firewalla/config/post_main.d/
# DNS over HTTPS must be disabled in Firewalla app


# set id with your own NextDNS config ID
# set IP with your Firewalla local lan IP
id=
IP=

# check for configuration
if [[ -z $id ]] ; then
        echo -e "Your nextdns ID is not set.\nEdit $install and run again."
        exit
elif [[ -z $IP ]] ; then
        echo -e "Your Firewalla IP is not set.\nEdit $uninstall and run again."
        exit
else
        echo -e "Fully configured and ready to go!\n\n"
fi

# Install script if not installed. 
install=/home/pi/.firewalla/config/post_main.d/install_nextdnscli.sh 
if [ ! -f "$install" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh > $install
        chmod +x $install
        echo "install saved."
else
        echo "install in place. "
fi

# Install Uninstall script if not installed
uninstall=/home/pi/.firewalla/config/post_main.d/uninstall_nextdnscli.nosh 
if [ ! -f "$uninstall" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/uninstall_nextdns_cli.nosh > $uninstall
        chmod +x $uninstall
        echo "uninstall saved."
else
        echo "uninstall in place"
fi

# install NextDNS CLI
if [ -z "$(command -v nextdns)" ] ; then 
        sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg
        echo "deb [signed-by=/usr/share/keyrings/nextdns.gpg] https://repo.nextdns.io/deb stable main" | sudo tee /etc/apt/sources.list.d/nextdns.list
        unalias apt
        sudo apt update
        sudo apt install nextdns
else
        echo "nextdns already installed..."
fi

# enable NextDNS caching: https://github.com/nextdns/nextdns/wiki/Cache-Configuration
# set discovery-dns to IP of Firewalla local DNS
# set NextDNS CLI to listen on local network IP (instead of 127.0.0.1 -- allows DHCP host resolution in NextDNS logs)
# define listen port instead of relying on -setup-router
# sudo nextdns install -config $id -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns $IP/24 -listen ${IP}:5555

sudo nextdns install \
-config ${IP}/24=${id} \
-config -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns ${IP} -listen ${IP}:5555 
# Note if you want to add additional IP ranges or mac addressses stick them all together first, followed by the 
# -report-client-info line. For example: 
# -config 12:99:41:ff:59:1a=${idm} \

sudo nextdns restart

# sudo nextdns install -config $id -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns $IP -listen ${IP}:5555

# alternate command to implement conditional configuration: https://github.com/nextdns/nextdns/wiki/Conditional-Configuration
# sudo nextdns install -config $IP/24=abcdef -config 123456 -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns 10.10.12.1 -listen 10.10.12.1:5555

# Add dnsmasq integration to enable client reporting in NextDNS logs: https://github.com/nextdns/nextdns/wiki/DNSMasq-Integration

cat > /home/pi/.firewalla/config/dnsmasq/mynextdns.conf << EOF
server=${IP}#5555
add-mac
add-subnet=32,128
EOF

# restart Firewalla DNS service
sudo systemctl restart firerouter_dns.service

echo "nextdns is... $(sudo nextdns status)"

# Install validation Script if not installed. 
nextdnstest=/data/nextdnstest.sh
if [ ! -f "$nextdnstest" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/nextdnstest.sh > $nextdnstest
        chmod +x $nextdnstest
        echo "test saved."
else
        echo "test in place."
fi

# Install data for IFTTT notification
nextdnsdata=/data/nextdnsdata.txt
if [ ! -f "$nextdnsdata" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/nextdnsdata.txt > $nextdnsdata
        chmod +x $nextdnsdata
        echo "data saved."
else
        echo "data in place."
fi
