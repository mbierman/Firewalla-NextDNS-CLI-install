#!/usr/bin/bash 

sudo docker container stop pihole && sudo docker container rm pihole
# sudo rm -rf /data/pi-hole
rm /home/pi/.firewalla/run/docker/pi-hole/docker-compose.yaml
sudo systemctl stop docker-compose@pi-hole
rm /home/pi/.firewalla/config/post_main.d/start_pihole.sh
