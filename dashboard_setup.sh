#! /bin/bash
sudo apt update && sudo apt upgrade -y
echo #! /bin/bash > ~/Desktop/dashboard.sh
echo firefox -kiosk "portal.office.com" >> ~/Desktop/dashboard.sh