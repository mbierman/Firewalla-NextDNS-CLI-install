#!/bin/bash

# 1.0

# install & configure NextDNS CLI on startup of Firewalla
# file goes in: /data/nextdnstest.sh
# DNS over HTTPS must be disabled in Firewalla app


# no need to edit these
dir=$(dirname "$0")
IFTTTKEY="$(cat $dir/nextdnsdata.txt | grep IFTTTKEY | cut -f2 -d "=" )"
IFTTTrigger="$(cat $dir/nextdnsdata.txt | grep IFTTTTrigger | cut -f2 -d "=" )"
IMAGE="https://icons-for-free.com/download-icon-nextdns-1330289847268527500_256.png"
URL="http://pi.hole/admin" # opens the firewalla app on iOS 
name=$(redis-cli get groupName)
name="$(echo $name | sed -e "s|’|'|")"
edate=$(date +'%a %b %d %H:%M:%S %Z %Y')
json='{"value1":"nextDNS on '$name' is not running @ '$edate'.","value2":"'$URL'","value3":"'$IMAGE'"}'

# Install Script if not installed. 
install=/home/pi/.firewalla/config/post_main.d/install_nextdnscli.sh 
if [ ! -f "$install" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh > $install
        chmod +x $install
        echo install saved.
else
        echo install in place. 
fi

# Install Uninstall script if not installed
uninstall=/home/pi/.firewalla/config/post_main.d/uninstall_nextdnscli.nosh 
if [ ! -f "$uninstall" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/uninstall_nextdns_cli.nosh > $uninstall
        chmod +x $uninstall
        echo uninstall saved.
else
        echo uninstall in place
fi

pushAlert () {
# This requires an IFTTT pro key
if [ -n "IFTTTKEY" ]; then
        curl -X POST -H "Content-Type: application/json" --data "$json" https://maker.ifttt.com/trigger/$IFTTTrigger/with/key/$IFTTTKEY
fi
}

# Install nextdns if not installed
nextinstalled="$(command -v nextdns)"
if [ "$(command -v nextdns)" != "/usr/bin/nextdns" ] ; then
        curl -s -L -C- https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh | cat <(cat <(bash))
else
        echo nextdns is installed!
fi

checkthis () {
        status="$(sudo nextdns status)"
        if [ "$status" != "running" ]; then
                echo not running
        else
                echo running
                echo nextdns: $status
        fi
}

for i in {1..10}; do
        checkthis 
        if [ "$status" = "running" ]; then
                echo "test complete"
                exit
        else 
                sudo nextdns restart 
                pushAlert $URL $IMAGE
                echo $edate nextdns failed >> /data/logs/nextdns.log
        fi
done