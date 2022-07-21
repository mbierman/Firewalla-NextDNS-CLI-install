#!/usr/bin/bash

sudo docker container stop pihole && sudo docker container rm pihole
# sudo rm -rf /data/pi-hole # use cautiously! this will peranently remove settings.
echo -e "\n\nYou may also want to run \`sudo rm -rf /data/pi-hole\` but that will remove all pi-hole settings so be cautious."\n\n"
rm /home/pi/.firewalla/run/docker/pi-hole/docker-compose.yaml
sudo systemctl stop docker-compose@pi-hole
rm /home/pi/.firewalla/config/post_main.d/start_pihole.sh
sudo docker stop cloudflared
sudo docker stop cloudflared && sudo docker container rm cloudflared
sudo docker image prune -f
sudo docker system prune -f 
sudo docker container prune -f 
