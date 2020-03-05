<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       01-30-2020
    Language:   PowerShell
    Purpose:    Runs throguh basic troubleshooting steps for a broken Start Menu in Windows 10.
    Last Edit:  01-30-2020
    Version:    1.0.1

    TASKS:
    -Run SFC scan
    -Reinstall Windows apps
#>

#Run SFC scan
Write-Host "Scanning file system for errors..."
sfc /scannow | Set-Content -Path "$env:SystemDrive\Users\$env:USERNAME"
Write-Host "Scan complete. Results can be found on your desktop."

#Reinstall Windows apps
$install = Read-Host -Prompt "Would you like to reinstall default apps? (y/n)"
if ($install -eq "y") {
    Get-AppXPackage -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}