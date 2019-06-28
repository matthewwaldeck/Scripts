##################################################
# INTRO
# This little script generates a text file
# containing a list of all software installed
# on the current computer, as well as some
# basic information about each item.
##################################################

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation |
Format-Table –AutoSize > C:\Users\$env:UserName\Desktop\InstalledPrograms.txt