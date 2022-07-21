# Install UniFi Controller in Docker on Firewalla Gold or Purple

This is a script for installing pi-hole container on Firewalla Gold or Purple. It is based on the [Firewalla tutorial](https://help.firewalla.com/hc/en-us/articles/360051625034-Guide-How-to-install-Pi-Hole-on-Gold-Purple-Beta-) and has been tested on 1.974.

![image](https://user-images.githubusercontent.com/1205471/180276302-1dfdb91f-952c-4194-8d06-371f1c14912d.png)


To install:
1. SSH into your Firewalla ([learn how](https://help.firewalla.com/hc/en-us/articles/115004397274-How-to-access-Firewalla-using-SSH-) if you don't know how already.)

2. If you want regular pi-hole, copy the line below and paste into the Firewalla shell and then hit enter. 

```
curl -s -L -C- https://raw.githubusercontent.com/mbierman/pihole-installer-for-Firewalla/main/pihole_docker_install.sh | cat <(cat <(bash))
```

If you want pi-hole with DoH, copy the line below instead and paste into the Firewalla shell and then hit enter.
```
curl -s -L -C- https://raw.githubusercontent.com/mbierman/pihole-installer-for-Firewalla/main/pihole_docker_install.sh | cat <(cat <(bash -s -- doh))
```

Now go to the network settings on Firewalla App, assign `172.16.0.2` as the primary DNS server for all networks that you want to enable Pi-Hole and disable DoH or Unbound on these networks.

1. Tap on Network Manager. 
1. Tap on the Top right edit button.
1. Tap on each LAN or VLAN segment you want to use pi-hole on.
1. Scroll down and change the primary DNS to `172.16.0.2`. leave the secondary DNS empty.
1. Save and you should be able to see DNS requests coming up in the management console. Another test is to block something obvious like facebook.com in pihole and try to reach it. 

Note, if all is working well, if you go to [browserleaks.com/dns](https://browserleaks.com/dns) you should see the upstream DNS servers you set in pi-hole if you are using unencrypted DNS. If you are using 


**Standard disclaimer:** I can not be responsible for any issues that may result. Nothing in the script should in any way, affect firewalla as a router or comprimise security. Happy to answer questions though if I can. :)

# Uninstalling
Instructions in progress...

These are the basic steps to uninstall. Also included in the uninstall script above. This could probably be made a little more rigorous but will do for now.  

``` shell
sudo docker container stop pihole && sudo docker container rm pihole
sudo rm -rf /data/pi-hole # use cautiously! this will peranently remove settings.
rm /home/pi/.firewalla/run/docker/pi-hole/docker-compose.yaml
sudo systemctl stop docker-compose@pi-hole
rm /home/pi/.firewalla/config/post_main.d/start_pihole.sh
```


There are lots of pihole communities on [Reddit](https://www.reddit.com/r/pihole/). If you have pi-hole questions, please check there. 
