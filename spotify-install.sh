#! /bin/bash

#This script automates installing Spotify via apt.
#https://www.spotify.com/us/download/linux/

echo "Installing repository..."
sleep 1
sudo apt-get update
sudo apt-get install curl -qq
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
echo "Done!"
sleep 1
echo "Installing Spotify client..."
sleep 1
sudo apt-get update && sudo apt-get install spotify-client -y
echo "Done!"
sleep 1
