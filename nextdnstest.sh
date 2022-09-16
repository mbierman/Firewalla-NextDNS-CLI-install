#!/bin/bash

# 2.1.1

#  Check to see if nextDNS is running and alert if not. 
# file goes in: /data/nextdnstest.sh
# DNS over HTTPS must be disabled in Firewalla app

# no need to edit these
dir=$(dirname "$0")
logs=/data/logs/nextdns.log
IFTTTKEY="$(cat $dir/nextdnsdata.txt | grep IFTTTKEY | cut -f2 -d "=" )"
IFTTTrigger="$(cat $dir/nextdnsdata.txt | grep IFTTTTrigger | cut -f2 -d "=" )"
IMAGE="https://icons-for-free.com/download-icon-nextdns-1330289847268527500_256.png"
URL="http://pi.hole/admin" # opens the firewalla app on iOS 
name=$(redis-cli get groupName)
name="$(echo $name | sed -e "s|’|'|")"
edate=$(date +'%a %b %d %H:%M:%S %Z %Y')
tries=0

# Install Script if not installed. 
install=/home/pi/.firewalla/config/post_main.d/install_nextdnscli.sh 
if [ ! -f "$install" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh > $install
        chmod +x $install
        echo "✅  install saved."
else
        echo "✅  install is installed."
fi

# Install Uninstall script if not installed
uninstall=/home/pi/.firewalla/config/post_main.d/uninstall_nextdnscli.nosh 
if [ ! -f "$uninstall" ] ; then
        curl https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/uninstall_nextdns_cli.nosh > $uninstall
        chmod +x $uninstall
        echo "✅  uninstall saved."
else
        echo "✅  uninstall is installed."
fi

pushAlert () {
# This requires an IFTTT pro key
if [ -n "IFTTTKEY" ]; then
        curl -X POST -H "Content-Type: application/json" --data "$json" https://maker.ifttt.com/trigger/$IFTTTrigger/with/key/$IFTTTKEY
fi
}

# Install nextdns 
nextinstalled="$(command -v nextdns)"
if [ "$(command -v nextdns)" != "/usr/bin/nextdns" ] ; then
        curl -s -L -C- https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh | cat <(cat <(bash))
else
        echo "✅  nextdns is installed."
	current="$(curl -sL https://api.github.com/repos/nextdns/nextdns/releases/latest  | jq -r '.tag_name' | sed -e 's/v//g')"
	installed=$(sudo nextdns version | cut -f3 -d' ')
	if [ "$installed" != "$current" ]; then
		echo "nextdns update available!"
		sudo nextdns upgrade
		echo "$edate next dns has been updated from $installed to $current" >> $logs
	else
		echo "✅  nextdns is up to date"
	fi
fi

checkthis () {
        status="$(sudo nextdns status)"
        if [ "$status" != "running" ]; then
                echo "❌  not running"
        else
                echo "✅  nextdns: $status"
        fi
}

checkthis 
while [  "$status" != "running" ]; do
	tries=$(expr $tries + 1)
	echo $tries
	json='{"value1":"nextDNS on '$name' is not running @ '$edate'. '$tries' tries","value2":"'$URL'","value3":"'$IMAGE'"}'
	sudo nextdns restart 
	echo restarting... 
        pushAlert $URL $IMAGE $i
        echo $edate nextdns failed try:${tries} >> $logs
	sleep 15
	if [ $tries -ge 20 ]; then
		exit
	fi
	checkthis
done

if [  "$status" != "running" ]; then
	echo "✅  all tests complete"
fi
