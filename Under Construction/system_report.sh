#!/bin/bash

# Author: Matt Waldeck
# Date: 2024-04-19
# Updated: 2024-04-19
# Purpose: Write out the specifications and status of the current computer to the terminal.

# Hardware Check
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