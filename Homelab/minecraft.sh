#!/bin/bash

# Install dependancies.
sudo apt install nano screen

# Download server version 1.20.6
wget https://piston-data.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar

# Start the server.
screen
java -Xms1024G -Xmx4G -jar minecraft_server_1.20.6.jar nogui

# Disconnect from screen session with CTRL+A+D.