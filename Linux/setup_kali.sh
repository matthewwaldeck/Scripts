#!/bin/bash

#Kali Linux setup script version 1.0.0 by Matt Waldeck
#This script will automate some of the little tweaks that I like to make to Kali on a fresh install with XFCE.

#Hardware Check
clear
echo "Processor:"
lscpu | grep "Model name:"
lscpu | grep "Thread(s) per core:"
lscpu | grep "Core(s) per socket:"
lscpu | grep "CPU min MHz:"
lscpu | grep "CPU max MHz:"
echo
echo "Memory:"
lsmem | grep "Total online memory:"
lsmem | grep "Total offline memory:"
echo
echo "GPU:"
lspci | grep "VGA compatible controller:"
echo
echo "USB Devices:"
lsusb
echo
echo "Storage Devices:"
df -h
echo

#Confirm before continuing with setup
while true; do
read -p "Do you want to proceed? (y/n) " yn
case $yn in
	[yY] )
        clear
        echo "Beginning setup...";
		break;;
	[nN] )
        clear
        echo "Exiting...";
		exit;;
	* )
        clear
        echo "invalid response!";;
esac
done

#Add the System Load Monitor plugin to the panel.
xfce4-panel --add=systemload

#Install updates
sudo apt update
sudo apt upgrade -y

#Download all available wallpapers. I like options.
sudo apt install kali-wallpapers-all -y

#Install applications & clean up
sudo apt install neofetch htop -y
sudo apt autoremove

#Complete
clear
neofetch