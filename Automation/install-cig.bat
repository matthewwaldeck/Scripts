@ECHO off
:: Downloads the Cowan TeamViewer app on a user's computer.
:: Makes a copy on the desktop and renames to "CIG".

:: Download custom TeamViewer client
ECHO Downloading...
set download="https://customdesign.teamviewer.com/download/version_15x/enzttzn_windows/TeamViewerQS.exe"
cd %USERPROFILE%\Downloads
powershell -Command "(New-Object Net.WebClient).DownloadFile('%download%', 'cowanqs.exe')"
ECHO Done!

:: Copy downloaded file to desktop and rename to CIG.exe
:1
if exist "%USERPROFILE%\Downloads\cowanqs.exe" (
copy %USERPROFILE%\Downloads\cowanqs.exe %USERPROFILE%\Desktop\CIG.exe
pause
exit
) else (
goto :1
)