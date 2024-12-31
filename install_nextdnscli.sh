#!/bin/bash
# 2.7.1
# Based on a script by Brian Curtis 
# https://help.firewalla.com/hc/en-us/community/posts/7469669689619-NextDNS-CLI-on-Firewalla-revisited-working-DHCP-host-resolution-in-NextDNS-logs-

# install & configure NextDNS CLI on startup of Firewalla:
# file goes in: /home/pi/.firewalla/config/post_main.d/
# DNS over HTTPS must be disabled in Firewalla app

# set id with your own NextDNS config ID
# set IP with your Firewalla local lan IP
# you can set up different profiles for different LANs if you wish 
# you can use the same profile on more than one LAN if you wish. 
# the config section below has to be updated if you add more than one LAN. 
id=
IP=
# Put your OpenVPN and WireGuard IP ranges here. 

# These are optional. 
OpenVPNID=
OpenVPNIP=
WireGuardID=
WireGuardIP=
# If you put your "linked IP" from nextDNS here your DNS will be updated when you start nextDNS. 
# you can also use your Firewalla DDNS in the nextDNS console, but remember to update it if that changes 
# (e.g. you reinstall Firewalla) 
DDNS=

case $1 in  
        "-n" | "-now")
                echo -e "\nReady to rock."
        ;;  
        *)  
        total_seconds=130

        while [ $total_seconds -gt 0 ]; do
                minutes=$((total_seconds / 60))
                seconds=$((total_seconds % 60))

                printf "\rStarting in: %02d:%02d" $minutes $seconds
                sleep 1
                ((total_seconds--))
        done

        echo -e "\nReady to rock."
        ;;  
esac

if [ -f /data/stopnextdns ] ; then
        echo "❌  not starting nextDNS" 
        exit
fi

DIR="/home/pi/.firewalla/config/post_main.d"
if [ ! -d  $DIR ]; then
	mkdir $DIR
	chown pi $DIR
	chmod 777 $DIR
fi

# Install validation script if not installed. 
file=/data/nextdnstest.sh
if [ ! -f "$file" ] ; then
	sudo touch $file
	sudo chown pi $file
	sudo chmod +wx $file
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/nextdnstest.sh > $file
        echo "✅ test saved."
else
        echo "✅ test in place."
fi

# Install stop Script if not installed. 
file=/data/nextdnsstop.sh
if [ ! -f "$file" ] ; then
	sudo touch $file
	sudo chown pi $file
	sudo chmod +wrx $file
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/nextdnsstop.sh > $file
        echo "✅ stop saved."
else
        echo "✅ stop in place."
fi

# Install data for IFTTT notification
file=/data/nextdnsdata.txt
if [ ! -f "$file" ] ; then
	sudo touch $file 
	sudo chmod +rw $file
	sudo chown pi $file
        echo "✅ data saved."
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/nextdnsdata.txt >> $file
else
        echo "✅ data in place."
fi


# Install Uninstall script if not installed
file=/home/pi/.firewalla/config/post_main.d/uninstall_nextdnscli.nosh
if [ ! -f "$file" ] ; then
	touch $file
	chown pi $file
	chmod +xw $file
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/uninstall_nextdns_cli.nosh > $file
        echo "✅  uninstall saved."
else
        echo "✅  uninstall in place.."
fi

# Install script if not installed. 
file=/home/pi/.firewalla/config/post_main.d/install_nextdnscli.sh 
if [ ! -f "$file" ] ; then
	touch $file
	chown pi $file
	chmod +xw $file
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh >> $file
        echo "✅  install saved."
else
        echo "✅  install in place. "
fi


# check for configuration
if [[ -z $id ]] ; then
        echo -e "Your nextdns ID is not set.\nEdit using your favorite editor (vi is already installed on Firewalla\n\n \$ vi $file \n\n then run\n \$ $file"
        exit
elif [[ -z $IP ]] ; then
        echo -e "Your Firewalla IP is not set.\nEdit using your favorite editor (vi is already installed on Firewalla) and run $file ."
        exit
else
        echo -e "Fully configured and ready to go!\n\n"
fi


# install NextDNS CLI
if [ -z "$(command -v nextdns)" ] ; then
	sudo apt install ca-certificates
	sudo wget -qO /usr/share/keyrings/nextdns.gpg https://repo.nextdns.io/nextdns.gpg
	echo "deb [signed-by=/usr/share/keyrings/nextdns.gpg] https://repo.nextdns.io/deb stable main" | sudo tee /etc/apt/sources.list.d/nextdns.list
	sudo apt update
	sudo apt install nextdns
else
	echo "✅  nextdns already installed..."
	echo "Checking for nextdns update..."
	sudo nextdns upgrade
fi

# Create settings file
cat > /home/pi/.firewalla/config/dnsmasq/mynextdns.conf << EOF
server=${IP}#5555
add-mac
add-subnet=32,128
EOF


# Configuration Section 
# modify as needed
# Modify as needed. remove "#" vbefor each linne
# this is an absolute minimal config. 
# sudo nextdns install \
# -config $id \
# -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns ${IP} -listen ${IP}:5555 

# Example
# Modify as needed. remove "#" vbefor each line and all the comments but leave the "\" and the end of each line
sudo nextdns install \
# -config ${IP}/24=${id} \  # the IP is defined above. You can configure an entire network at once this way e.g. "192.168,0.1" 
# -config $OpenVPN/24=$VPNID \ # this uses the IP for your OpenVPN defined above to apply to OpenVPN connections
# -config $WireGuard/24=$VPNID \ # this uses the IP for your WireGuard defined above to apply to WireGuard connections
# -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns ${IP} -listen ${IP}:5555



# alternate command to implement conditional configuration: https://github.com/nextdns/nextdns/wiki/Conditional-Configuration
# sudo nextdns install \
# -config $IP/24=abcdef \
# -config 123456 \
# -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns 10.10.12.1 -listen 10.10.12.1:5555

# IF you want to apply this to just one network put each network as follows (this one uses the variable IP defined above) 
# -config ${IP}/24=${id} \

# For example, you could have a different profile for IoT devices or Guest Networks. 

# You can also put a config for an individual mac address like so. Edit to include your actual mac addres and
# put thse before the config above.
# -config xx:yy:zz:aa:bb:cc=${id} \

# For example if you want an Apple TV to use a different nextDNS profile which has different filters. 

# You can also set profiles for OpenVPN or WireGuard Profiles. Put thse before the config above.
# -config $OpenVPNIP/24=$VPNID \
# -config $WireGuardIP/24=$VPNID \

# This assumes using the Variables defined above. 

# See NextDNS caching: https://github.com/nextdns/nextdns/wiki/Cache-Configuration
# set discovery-dns to IP of Firewalla local DNS
# set NextDNS CLI to listen on local network IP (instead of 127.0.0.1 -- allows DHCP host resolution in NextDNS logs)
# define listen port instead of relying on -setup-router
# sudo nextdns install -config $id -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns $IP/24 -listen ${IP}:5555

# sudo nextdns install -config $id -report-client-info -cache-size=10MB -max-ttl=5s -discovery-dns $IP -listen ${IP}:5555

# Add dnsmasq integration to enable client reporting in NextDNS logs: https://github.com/nextdns/nextdns/wiki/DNSMasq-Integration

curl -s $DDNS && echo " DDNS updated..."

# sudo nextdns restart 
echo "Restarting Firewalla DNS..." && \
sudo systemctl restart firerouter_dns.service && \
sleep 20 && echo "nextdns is... $(sudo nextdns status)"
