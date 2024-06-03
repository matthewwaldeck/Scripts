@echo off

:: Author: Matt Waldeck
:: Date: May 31, 2024
:: Updated: May 31, 2024
:: Purpose: Clean up Windows to reclaim disk space, performance, and Privacy (TBD).

:: Clean up preinstalled MS bloat with Powershell.
:: Get-AppxPackage {PACKAGE_NAME} -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *Advertising.Xaml* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *GetHelp* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *Getstarted* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *Microsoft3DViewer* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *MicrosoftOfficeHub* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *MicrosoftSolitaireCollection* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *MixedReality.Portal* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *Office.OneNote* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *People* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *SkypeApp* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *Wallet* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *WindowsAlarms* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *WindowsFeedbackHub* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *WindowsMaps* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *YourPhone* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *ZuneMusic* -AllUsers | Remove-AppxPackage
powershell.exe Get-AppxPackage *ZuneVideo* -AllUsers | Remove-AppxPackage

:: Antivirus removal
if exist "%PROGRAMFILES(X86)%\Norton Security" (
start "./tools/Norton_Remover.exe" /norestart /noreboot > NUL 2>&1
pause
)
if exist "%PROGRAMFILES(X86)%\Norton Internet Security" (
start "./tools/Norton_Remover.exe" /norestart /noreboot > NUL 2>&1
pause
)
if exist "%PROGRAMFILES(X86)%\McAfee" (
start "./tools/McAfee_Remover.exe" > NUL 2>&1
pause
)
if exist "%PROGRAMFILES%\Spybot - Search & Destroy 2" (
start "%PROGRAMFILES%\Spybot - Search & Destroy 2\unins000.exe" > NUL 2>&1
)