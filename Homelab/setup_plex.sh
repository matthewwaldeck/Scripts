#!/bin/bash

#Author: Matt Waldeck
#Date: April 16, 2024
#Updated: April 17, 2024
#Purpose: Automate installation and setup of Plex Media Server.

#Start by installing updates.
sudo apt update
sudo apt upgrade -y

#Add repository and GPG keys.
echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -

#Install the server and CIFS utilities.
sudo apt update
sudo apt install plexmediaserver -y
sudo apt install cifs-utils -y

#Create mountpoint for SMB share.
mkdir /media/apollo

#Create hidden file in home directory with share credentials.
clear
read -p "Please enter the desired username " smbusername 
echo "username=$smbusername" > /home/mwaldeck/.smbcredentials
clear
read -p "Please enter the desired password " smbpassword
echo "password=$smbpassword" >> /home/mwaldeck/.smbcredentials
chmod 600 /home/mwaldeck/.smbcredentials
clear

#Add the share to the fstab file for mounting on boot.
echo "//apollo.local/media /media/apollo cifs credentials=/home/mwaldeck/.smbcredentials,iocharset=utf8 0 0" >> /etc/fstab

#Manually mount the share.
sudo mount -a
clear
