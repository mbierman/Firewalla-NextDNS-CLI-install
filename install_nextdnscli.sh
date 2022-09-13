!/bin/bash
dir=$(dirname "$0")
IFTTTKEY="$(cat $dir/nextdnsdata.txt | grep IFTTTKEY | cut -f2 -d "=" )"
IFTTTrigger="$(cat $dir/nextdnsdata.txt | grep IFTTTTrigger | cut -f2 -d "=" )"
IMAGE="https://icons-for-free.com/download-icon-nextdns-1330289847268527500_256.png"
URL="http://pi.hole/admin" # opens the firewalla app on iOS 
name=$(redis-cli get groupName)
name="$(echo $name | sed -e "s|’|'|")"
edate=$(date +'%a %b %d %H:%M:%S %Z %Y')
json='{"value1":"nextDNS on '$name' is not running @ '$edate'.","value2":"'$URL'","value3":"'$IMAGE'"}'

pushAlert () {
# This requires an IFTTT pro key
if [ -n "IFTTTKEY" ]; then
        curl -X POST -H "Content-Type: application/json" --data "$json" https://maker.ifttt.com/trigger/$IFTTTrigger/with/key/$IFTTTKEY
fi
}


installed="$(command -v nextdns)"
if [ "$(command -v nextdns)" != "/usr/bin/nextdns" ] ; then
        echo nextdns not installed
        curl -s -L -C- https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh | cat <(cat <(bash))
else
        echo nextdns is installed!
fi

checkthis () {
        status="$(sudo nextdns status)"
        if [ "$status" != "running" ]; then
                status=false
        else
                status=true:
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
