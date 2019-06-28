<#

    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-28-2019
    Language:   PowerShell
    Purpose:    Lists all installed software and their information.
    Last Edit:  06-28-2019
    Version:    v1.0.0

#>

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation |
Format-Table –AutoSize > C:\Users\$env:UserName\Desktop\InstalledPrograms.txt