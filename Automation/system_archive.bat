:: AUTHOR - Matt Waldeck
:: DATE - March 1, 2024
:: LAST UPDATE - March 5, 2024
:: VERSION - 1.2

:: NOTES
:: This script will save user data and system details to a temp folder on the C: drive.
:: This can be used to recover things like bookmarks if data loss occurs.
:: This script should be run using the user account that is to be backed up.

:: VERSION HISTORY
:: 1.2 - Added support for user folder and system registry backups.
:: 1.1 - Added taskbar backup, Internet Explorer bookmark support, and more system logging.
:: 1.0 - Initial release. Bookmark backups and some system information recorded.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Echo off, variables, and paths.
@ECHO off
set registry=n
set files=n
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
robocopy %bookmarks_chrome% %archive%\Bookmarks\Chrome > nul
robocopy %bookmarks_edge% %archive%\Bookmarks\Edge > nul
robocopy %bookmarks_ie% %archive%\Bookmarks\IE /S /Y > nul
echo Done.
echo.

::Save taskbar pins.
echo Backing up taskbar pins...
robocopy %taskbar% %archive%\TaskBar > nul
echo Done.
echo.

:: Save list of installed software.
echo Recording system information...
systeminfo > %archive%\systeminfo.txt
wmic product get name,Version,InstallDate > %archive%\software.txt
wmic path softwarelicensingservice get OA3xOriginalProductKey > %archive%\windows_key.txt
net user > %archive%\local_users.txt
echo Done.
echo.

:: Optionally backup system registry. (Default=no)
set /p registry="Would you like to back up the registry? (y/N) "

if %registry%==n (
    echo System registry will not be backed up.
    echo.
)

if %registry%==y (
    echo Backing up system registry...
    reg export HKLM %archive%\%COMPUTERNAME%.reg \y
    echo Done.
    echo.
)

:: Optionally back up user files. (Default=no)
set /p files="Would you like to back up the current user's files? (y/N) "

if %files%==y (
    echo Backing up current user folder...
    robocopy C:\Users\%USERNAME% %archive%\%USERNAME% /E > nul
    echo Done.
)

if %files%==n (
    echo User folder will not be backed up.
)

echo.
echo Backup complete!
pause