# Install nextDNS CLI on Firewalla Gold or Purple

WIP not ready for use

This is a script for installing nextDNS CLI container on Firewalla Gold or Purple. It is based on the [a script by Brian Curtis ](https://help.firewalla.com/hc/en-us/community/posts/7469669689619-NextDNS-CLI-on-Firewalla-revisited-working-DHCP-host-resolution-in-NextDNS-logs- and has been tested on 1.974.


# Notes
- nextdns CLI runs fine on Purole or Gold.



To install:
1. SSH into your Firewalla ([learn how](https://help.firewalla.com/hc/en-us/articles/115004397274-How-to-access-Firewalla-using-SSH-) if you don't know how already.)

2. Copy the line below and paste into the Firewalla shell and then hit enter. 

```
curl -s -L -C- https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh | cat <(cat <(bash))
```

3. Now go to the network settings on Firewalla App, assign `172.16.0.2` as the primary DNS server for all networks that you want to enable Pi-Hole and disable DoH or Unbound on these networks.

     1. Tap on Network Manager. 
     1. Tap on the Top right edit button.
     1. Tap on each LAN or VLAN segment you want to use pi-hole on.
     1. Scroll down and change the primary DNS to `172.16.0.2`. Leave the secondary DNS empty.
     

# Testing
1. After completing the steps above, you should be able to see DNS requests coming up in the pi-hole management console [172.16.0.2/admin](http://172.16.0.2/admin).
2. Try to block something obvious in pi-hole like facebook.com and try to reach it you should be blocked. 
3. If you go to [browserleaks.com/dns](https://browserleaks.com/dns) you should see the upstream DNS servers you set in pi-hole if you are using unencrypted DNS. 


**Standard disclaimer:** I can not be responsible for any issues that may result. Nothing in the script should in any way, affect firewalla as a router or comprimise security. Happy to answer questions though if I can. :)

# Uninstalling

You can run this by copying this line and run it on firewalla to uninstall. 
```
curl -s -L -C- https://raw.githubusercontent.com/mbierman/pihole-installer-for-Firewalla/main/uninstall_pihole.sh | cat <(cat <(bash -x))
```

There are lots of pihole communities on [Reddit](https://www.reddit.com/r/pihole/). If you have pi-hole questions, please check there. 
