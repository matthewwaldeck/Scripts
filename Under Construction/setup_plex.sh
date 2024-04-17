#!/bin/bash

#Author: Matt Waldeck
#Date: April 16, 2024
#Updated: April 17, 2024
#Purpose: Automate installation and setup of Plex Media Server.
#Status: Untested.

#Start by installing updates & CIFS utilities.
sudo apt update
sudo apt upgrade -y
sudo apt install cifs-utils -y

#Create mountpoint for SMB share.
mkdir /media/apollo

#Create hidden file in home directory with share credentials.
clear
mkdir /home/mwaldeck/.smbcredentials
read -p "Please enter the desired username " smbusername 
echo "username=$smbusername" >> /home/mwaldeck/.smbcredentials
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