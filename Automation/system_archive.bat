:: AUTHOR - Matt Waldeck
:: DATE - March 1, 2024
:: LAST UPDATE - March 4, 2024

:: NOTES
:: This script will save user data to a folder on the current user's desktop.
:: This can be used to recover things like bookmarks if data loss occurs.
:: This script should be run using the user account that is to be backed up.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO off

::Path variables.
set archive=C:\Temp\%COMPUTERNAME%
set bookmarks_chrome="C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
set bookmarks_edge="C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"

:: Create folder structure.
mkdir %archive%
mkdir %archive%\Bookmarks\Chrome
mkdir %archive%\Bookmarks\Edge

:: Grab bookmarks.
:: Add Firefox support: https://support.mozilla.org/en-US/kb/profiles-where-firefox-stores-user-data
echo Backing up bookmarks...
copy %bookmarks_chrome% %archive%\Bookmarks\Chrome
copy %bookmarks_edge% %archive%\Bookmarks\Edge
echo Done.
echo.

:: Save list of installed software.
echo Recording system information...
systeminfo > %archive%\systeminfo.txt
wmic product get name > %archive%\software.txt
wmic path softwarelicensingservice get OA3xOriginalProductKey > %archive%\windows_key.txt
echo Done.
echo.