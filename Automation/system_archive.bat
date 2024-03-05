:: AUTHOR - Matt Waldeck
:: DATE - March 1, 2024
:: LAST UPDATE - March 4, 2024

:: NOTES
:: This script will save user data and system details to a temp folder on the C: drive.
:: This can be used to recover things like bookmarks if data loss occurs.
:: This script should be run using the user account that is to be backed up.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO off

::Path variables.
set archive=C:\Temp\%COMPUTERNAME%
set bookmarks_chrome="C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
set bookmarks_edge="C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"
set bookmarks_ie="C:\Users\%USERNAME%\Favorites"
set taskbar="C:\Users\waldeck-m\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"

:: Create folder structure.
mkdir %archive%
mkdir %archive%\Bookmarks\Chrome
mkdir %archive%\Bookmarks\Edge
mkdir %archive%\Bookmarks\IE
mkdir %archive%\TaskBar

:: Grab bookmarks.
:: Add Firefox support: https://support.mozilla.org/en-US/kb/profiles-where-firefox-stores-user-data
echo Backing up bookmarks...
xcopy %bookmarks_chrome% %archive%\Bookmarks\Chrome
xcopy %bookmarks_edge% %archive%\Bookmarks\Edge
xcopy %bookmarks_ie% %archive%\Bookmarks\IE /S /Y
echo Done.
echo.

::Save taskbar pins.
echo Backing up taskbar pins...
xcopy %taskbar% %archive%\TaskBar
echo Done.
echo.

:: Backup system registry.
:: Prompt for user input - would they like to back up the registry?
:: reg export HKLM %archive%\%COMPUTERNAME%.reg \y

:: Save list of installed software.
echo Recording system information...
systeminfo > %archive%\systeminfo.txt
wmic product get name,Version,InstallDate > %archive%\software.txt
wmic path softwarelicensingservice get OA3xOriginalProductKey > %archive%\windows_key.txt
net user > %archive%\local_users.txt
echo Done.
echo.