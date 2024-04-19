#!/bin/bash

# Author: Matt Waldeck
# Date: 2024-04-18
# Updated: 2024-04-18
# Purpose: Automate installation of Docker and a few of my favourite containers.

# Links
# Docker Engine: https://docs.docker.com/engine/install/ubuntu/
# Portainer: https://docs.portainer.io/start/install-ce/server/docker/linux
# UniFi: https://github.com/jacobalberty/unifi-docker
# Uptime Kuma: https://github.com/louislam/uptime-kuma

# Run the following command to uninstall all conflicting packages:
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the latest version of Docker.
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Portainer.
docker volume create portainer_data
sudo docker run -d --name portainer --restart=always -p 8000:8000 -p 9443:9443 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

# Install Heimdall.
whoami username
mkdir /home/$username/Docker
sudo docker run -d --name heimdall --restart=always -v /home/$username/docker/heimdall:/config -e PGID=1000 -e PUID=1000 -p 8080:80 -p 8443:443 linuxserver/heimdall

# Install Uptime Kuma.
sudo docker run -d --name uptime-kuma --restart=always -p 3001:3001 -v uptime-kuma:/app/data louislam/uptime-kuma:1