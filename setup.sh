#! /bin/bash

#Linux setup script version 0.5 by Matt Waldeck
#This script will automate some of the setup on new Debian-based installs.
#Support will be added for Arch-based distros later.
#See doc in CherryTree for more info and future plans.

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

echo "We need some information to configure Git later."
read -p "What is your email address? " email
read -p "What is your name? " name
clear

#Install Updates
sudo apt update
sudo apt upgrade -y

#Install Utilities
sudo apt install curl -y
sudo apt install git -y
sudo apt install gnome-tweaks -y
sudo apt install htop -y
sudo apt install lynx -y
sudo apt install neofetch -y

#Install necessary repos.
#Spotify
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

#Signal
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list

#Visual Studio Code
sudo apt-get install wget gpg -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt install apt-transport-https
rm -f packages.microsoft.gpg

#Install Software
sudo apt update
sudo apt install cherrytree -y
sudo apt install code -y
sudo apt install firefox -y
sudo apt install lutris -y #Not found.
sudo apt install qbittorrent -y
sudo apt install signal-desktop -y
sudo apt install spotify -y
sudo apt install vlc -y

#Set up Git
git config --global user.email "$email"
git config --global user.name "$name"

#Clean Up
sudo apt autoremove

#Complete
clear
neofetch