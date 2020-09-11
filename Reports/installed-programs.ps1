<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-28-2019
    Purpose:    Lists all installed software and their information.
    Last Edit:  09-11-2020
    Version:    v1.0.1
#>

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation |
Format-Table –AutoSize > C:\Users\$env:UserName\Desktop\InstalledPrograms.txt