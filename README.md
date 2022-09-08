# Install nextDNS CLI on Firewalla Gold or Purple

WIP not ready for use

This is a script for installing nextDNS CLI container on Firewalla Gold or Purple. It is based on the [a script by Brian Curtis ](https://help.firewalla.com/hc/en-us/community/posts/7469669689619-NextDNS-CLI-on-Firewalla-revisited-working-DHCP-host-resolution-in-NextDNS-logs- and has been tested on 1.974.


# Notes
- nextdns CLI runs fine on Purole or Gold.
- nextdns CLI runs nicely with Firewalla Unbound but so far it I have not been successful in getting it to work with DNS over HTTP (DoH). So if you care about using DoH, do not install nextDNS CLI. Instead, you can use nextDNS via Firewalla DoH. 



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
After completing the steps above, you can: 
1. Try 
```
dig github.com
; <<>> DiG 9.10.6 <<>> github.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 5679
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;github.com.			IN	A

;; ANSWER SECTION:
github.com.		10	IN	A	192.30.255.113

;; Query time: 20 msec
;; SERVER: 192.168.241.1#53(192.168.241.1)
;; WHEN: Thu Sep 08 10:56:06 PDT 2022
;; MSG SIZE  rcvd: 55
```
The SERVER line should match the Firewalla server you set if nextDNS CLI is working. OR 

2. You can try https://my.nextdns.io/ to see if it shows that nextDNS is working. 

Great resource for [all things nextDNS CLI](https://github.com/nextdns/nextdns/wiki).


**Standard disclaimer:** I can not be responsible for any issues that may result. Nothing in the script should in any way, affect firewalla as a router or comprimise security. Happy to answer questions though if I can. :)

# Uninstalling

You can run this by copying this line and run it on firewalla to uninstall. 
```
curl -s -L -C- https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/uninstall_nextdns_CLI.nosh | cat <(cat <(bash))
```

There are lots of nextDNS communities on Reddit. If you have nextDNS CLI questions, please check there.
