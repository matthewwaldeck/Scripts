#!/bin/bash

#This script will install the dependancies needed for WINE to run properly when used with Lutris.
#It is meant for use in Ubuntu and it's derivatives, such as Pop!_OS.

sudo dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/'
sudo apt update
sudo apt install --install-recommends winehq-staging
sudo apt install winetricks
