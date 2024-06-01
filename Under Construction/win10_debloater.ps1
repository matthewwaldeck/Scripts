<#
Author: Matt Waldeck
Date: May 31, 2024
Updated: May 31, 2024
Purpose: Clean up a fresh Windows 10 install to reclaim disk space, performance, and Privacy (TBD).
#>


# Clean up preinstalled MS bloat.
# Get-AppxPackage {PACKAGE_NAME} -AllUsers | Remove-AppxPackage
Get-AppxPackage *Advertising.Xaml* -AllUsers | Remove-AppxPackage
Get-AppxPackage *GetHelp* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Getstarted* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft3DViewer* -AllUsers | Remove-AppxPackage
Get-AppxPackage *MicrosoftOfficeHub* -AllUsers | Remove-AppxPackage
Get-AppxPackage *MicrosoftSolitaireCollection* -AllUsers | Remove-AppxPackage
Get-AppxPackage *MixedReality.Portal* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Office.OneNote* -AllUsers | Remove-AppxPackage
Get-AppxPackage *People* -AllUsers | Remove-AppxPackage
Get-AppxPackage *SkypeApp* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Wallet* -AllUsers | Remove-AppxPackage
Get-AppxPackage *WindowsAlarms* -AllUsers | Remove-AppxPackage
Get-AppxPackage *WindowsFeedbackHub* -AllUsers | Remove-AppxPackage
Get-AppxPackage *WindowsMaps* -AllUsers | Remove-AppxPackage
Get-AppxPackage *YourPhone* -AllUsers | Remove-AppxPackage
Get-AppxPackage *ZuneMusic* -AllUsers | Remove-AppxPackage
Get-AppxPackage *ZuneVideo* -AllUsers | Remove-AppxPackage