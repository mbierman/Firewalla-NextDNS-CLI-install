# Install nextDNS CLI on Firewalla Gold or Purple

This is a script for installing nextDNS CLI container on Firewalla Gold or Purple. It is based on [a script by Brian Curtis](https://help.firewalla.com/hc/en-us/community/posts/7469669689619-NextDNS-CLI-on-Firewalla-revisited-working-DHCP-host-resolution-in-NextDNS-logs-) and has been tested on 1.975.


# Notes
- nextdns CLI runs fine on Purple or Gold (I hve not tested anywhere else).
- nextdns CLI runs nicely with Firewalla Unbound, but so far it I have not been successful in getting it to work with Firewalla DNS over HTTP (DoH) but nextDNS CLI uses DoH. 

- Pros: 
   * Running nextDNS CLI as opposed to using Firewalla DoH > nextDNS, you can have DoH betwen FW and nextDNS and it shows individual client devices, not just your firewalla making all the requests. Less anonymous to be sure, but if you want to look at logs by device, that is handy. Note, it seems that is by IP (not mac address of course) so you may end up with the same device entered many times. :( I haven't found a solution to that yet. You can of course, always disable nextDNS logs if you like. 
   * This does not require disabling Firewalla DNS Booster... though I am still testing to see if there are any negative side effects. I'm worried that it may be side stepping Firewalla... stay tuned on that. 

- You cannot use Firewalla DoH and nextdns CLI though.





To install:
1. SSH into your Firewalla ([learn how](https://help.firewalla.com/hc/en-us/articles/115004397274-How-to-access-Firewalla-using-SSH-) if you don't know how already.)

2. Copy the line below and paste into the Firewalla shell and then hit enter. 

```
curl -s -L -C- https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/install_nextdnscli.sh | cat <(cat <(bash))
```
  

# Testing
After completing the steps above, you can: 

1. Open `https://test.nextdns.io/` 
![11662D0C-718C-4B7F-AC27-816FA02D4764](https://user-images.githubusercontent.com/1205471/189506662-a65c3b78-bc26-4d76-939c-1b75b9233c13.jpeg)


3. Try 
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

3. You can try https://my.nextdns.io/ to see if it shows that nextDNS is working. 

Great resource for [all things nextDNS CLI](https://github.com/nextdns/nextdns/wiki).


**Standard disclaimer:** I can not be responsible for any issues that may result. Nothing in the script should in any way, affect firewalla as a router or comprimise security. Happy to answer questions though if I can. :)

# Uninstalling

You can run this by copying this line and run it on firewalla to uninstall. 
```
curl -s -L -C- https://raw.githubusercontent.com/mbierman/Firewalla-NextDNS-CLI-install/main/uninstall_nextdns_CLI.nosh | cat <(cat <(bash))
```

This script will also be saved when you install and you can just run it locally:
```
/home/pi/.firewalla/config/post_main.d/uninstall_nextdnscli.nosh
```


There are lots of nextDNS communities on Reddit. If you have nextDNS CLI questions, please check there.
