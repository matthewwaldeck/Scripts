#! /bin/bash

#This script will install some basic pentesting and network assessment tools.
#It will be periodically updated with new tools.

#Install common pentesting tools
echo "Installing tools..."
sudo apt update
sudo apt install crunch -y
sudo apt install ffuf -y
sudo apt install hping3 -y
sudo apt install john -y
sudo apt install metasploit-framework -y
sudo apt install nmap -y
sudo apt install openvpn -y
sudo apt install wireshark -y
sudo apt install wpscan -y

#Install Sherlock
#https://github.com/sherlock-project/sherlock
git clone https://github.com/sherlock-project/sherlock.git ~/Downloads/sherlock
cd ~/Downloads/sherlock
python3 -m pip install -r requirements.txt

#Grab SecLists and throw them in the Documents folder.
echo "Cloning SecLists repo..."
git clone https://github.com/danielmiessler/SecLists.git ~/Downloads/SecLists

echo "Done."