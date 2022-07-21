# Install UniFi Controller in Docker on Firewalla Gold or Purple

This is a script for installing pi-hole container on Firewalla Gold or Purple. It is based on the [Firewalla tutorial](https://help.firewalla.com/hc/en-us/articles/360051625034-Guide-How-to-install-Pi-Hole-on-Gold-Purple-Beta-) and has been tested on 1.974.

To install:
1. SSH into your Firewalla ([learn how](https://help.firewalla.com/hc/en-us/articles/115004397274-How-to-access-Firewalla-using-SSH-) if you don't know how already.)

2. If you want regular pi-hole, copy the line below and paste into the Firewalla shell and then hit enter. 

```
curl -s -L -C- https://raw.githubusercontent.com/mbierman/pihole-installer-for-Firewalla/main/pihole_docker_install.sh | cat <(cat <(bash))
```

If you want pi-hole with DoH, copy the line below instead and paste into the Firewalla shell and then hit enter.
```
curl -s -L -C- https://raw.githubusercontent.com/mbierman/pihole-installer-for-Firewalla/main/pihole_docker_install.sh doh | cat <(cat <(bash))
```

Now go to the network settings on Firewalla App, assign 172.16.0.2 as the primary DNS server for all networks that you want to enable Pi-Hole and disable DoH or Unbound on these networks.

1. Tap on Network Manager. 
1. Tap on the Top right edit button. 
1. Tap on each LAN segment you want to change DNS to pi-hole. 
1. Scroll down and change the primary DNS to 172.16.0.2. leave the secondary DNS empty.
1. Save and you should be able to see DNS requests coming up in the management console.


**Standard disclaimer:** I can not be responsible for any issues that may result. Nothing in the script should in any way, affect firewalla as a router or comprimise security. Happy to answer questions though if I can. :)

# Uninstalling
Instructions in progress...

1. `sudo docker container stop pihole && sudo docker container rm pihole`
1. `sudo docker stop pihole`
1. `rm -rf /data/pi-hole`
1.  


There are lots of pihole communities on [Reddit](https://www.reddit.com/r/pihole/. If you have pi-hole questions, please check there. 
