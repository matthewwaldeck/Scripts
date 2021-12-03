@echo off
:::
:::      __    __ _      _           _        _ _           
:::     / /   / _| |    (_)         | |      | | |          
:::    / /_ _| |_| | __  _ _ __  ___| |_ __ _| | | ___ _ __ 
:::   / / _` |  _| |/ / | | '_ \/ __| __/ _` | | |/ _ \ '__|
:::  / / (_| | | |   <  | | | | \__ \ || (_| | | |  __/ |   
::: /_/ \__,_|_| |_|\_\ |_|_| |_|___/\__\__,_|_|_|\___|_|   
:::Version : 3.6.7

REM --> Display header
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
echo.

:: ADMIN
:-------------------------------------
REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%ERRORLEVEL%' EQU '5' (
echo Asking for admin access...
goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%TEMP%\getadmin.vbs"

"%TEMP%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%TEMP%\getadmin.vbs" ( del "%TEMP%\getadmin.vbs" )
pushd "%CD%"
cd /D "%~dp0"
:--------------------------------------

:: OS ARCHITECHTURE
:-------------------------------------
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
set WINVERSION=0
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%VERSION%" == "10.0" set WINVERSION=10
if "%VERSION%" == "6.3" set WINVERSION=8.1
if "%VERSION%" == "6.1" set WINVERSION=7
if "%VERSION%" == "6.0" set WINVERSION=VISTA
:-------------------------------------

:: SCRIPT VALIDATION
:-------------------------------------
powershell.exe -Command "& {$usage = (New-Object System.Net.WebClient).DownloadString('http://validation.afk.gscanada.info/inc/backend/validate.backend.inc.php?id=443943'); if ($usage -eq 1) {Write-Host This script has already been used. Please use the /afk website on each unit ...; $x = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); Remove-Item %0 -Force; kill -processname cmd}}"
:-------------------------------------

:: CREATE TEMPORARY FOLDER
:-------------------------------------
mkdir "%TEMP%\afk" > NUL 2>&1
:--------------------------------------

:: NETWORK TO PRIVATE
:-------------------------------------
if %WINVERSION%==10 (
powershell.exe Set-NetconnectionProfile -Name WPATubez -NetworkCategory Private -ErrorAction SilentlyContinue
powershell.exe Set-NetConnectionProfile -interfacealias Ethernet -NetworkCategory Private -ErrorAction SilentlyContinue
)
:--------------------------------------

:: POWER MODE
:-------------------------------------
echo Switching power mode...
for /f "tokens=4 delims= " %%a in ('POWERCFG -GETACTIVESCHEME') do @SET _DEFAULT_POWER_SCHEME="%%a"
copy /Y "\\192.168.8.10\afkcloud\core\windows\others\power_profile\nosleep.pow" "%TEMP%\afk" > NUL 2>&1
powercfg -import "%temp%\afk\nosleep.pow" 94442dba-3a44-4b44-a10c-097d37688760 > NUL 2>&1
powercfg -setactive 94442dba-3a44-4b44-a10c-097d37688760 > NUL 2>&1
:-------------------------------------

:: TRACER PATCH
:-------------------------------------
echo Launching TRACER from the network...
start /wait "" "\\192.168.8.10\afkcloud\core\windows\others\tracer\TRACER.exe" > NUL 2>&1
del "C:\A21BA6E8-8C91-4C97-854A-D034E76B7FA0" /q /s > NUL 2>&1
:-------------------------------------
:: CLOSE BROWSERS
:-------------------------------------
taskkill /im microsoftedge.exe /f > NUL 2>&1
taskkill /im iexplore.exe /f > NUL 2>&1
taskkill /im chrome.exe /f > NUL 2>&1
taskkill /im firefox.exe /f > NUL 2>&1
taskkill /im opera.exe /f > NUL 2>&1
:--------------------------------------

:: TIME ZONE
:-------------------------------------
echo Setting the timezone...
tzutil /s "Eastern Standard Time" > NUL 2>&1
sc config W32Time start=auto > NUL 2>&1
net start W32Time > NUL 2>&1
timeout 1 > NUL 2>&1
w32tm /resync > NUL 2>&1
w32tm /config /syncfromflags:MANUAL /reliable:yes /update /manualpeerlist:0.ca.pool.ntp.org > NUL 2>&1
w32tm /resync /rediscover > NUL 2>&1
:-------------------------------------

:: OEMCLEANER
:-------------------------------------
echo Deleting bloatwares with OEMCleaner...
start /wait "" "\\192.168.8.10\afkcloud\core\windows\oemcleaner\oemcleaner.bat" > NUL 2>&1
del "%PUBLIC%\Desktop\*.lnk" /F /Q /S > NUL 2>&1
del "%USERPROFILE%\Desktop\*lnk" /F /Q /S > NUL 2>&1
:-------------------------------------

:: SHOW DESKTOP ICONS
:-------------------------------------
echo Show desktop icons...
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /f /d "0" > NUL 2>&1
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /f /d "0" > NUL 2>&1
:-------------------------------------

:: ANTIVIRUS REMOVAL PROCESS
:-------------------------------------
echo Deleting present anti-virus...
REM --> NORTON
if exist "%PROGRAMFILES(X86)%\Norton Security" (
start "" "\\192.168.8.10\afkcloud\core\windows\av_removal\norton\norton_remover.exe" /norestart /noreboot > NUL 2>&1
echo Press a key after the anti-virus removal process...
pause > nul
)
if exist "%PROGRAMFILES(X86)%\Norton Internet Security" (
start "" "\\192.168.8.10\afkcloud\core\windows\av_removal\norton\norton_remover.exe" /norestart /noreboot > NUL 2>&1
echo Press a key after the anti-virus removal process...
pause > nul
)
REM --> MCAFEE
if exist "%PROGRAMFILES(X86)%\McAfee" (
start "" "\\192.168.8.10\afkcloud\core\windows\av_removal\mcafee\mc_remover.exe" > NUL 2>&1
echo Press a key after the anti-virus removal process...
pause > nul
)
REM --> BITDEFENDER
if exist "%PROGRAMFILES%\Bitdefender" (
start "" "\\192.168.8.10\afkcloud\core\windows\av_removal\bitdefender\bd_remover.exe"
echo Press a key after the anti-virus removal process...
pause > nul
)
REM --> AVG
if exist "%PROGRAMFILES%\AVG" (
start "" "\\192.168.8.10\afkcloud\core\windows\av_removal\avg\avg_remover.exe" > NUL 2>&1
echo Press a key after the anti-virus removal process...
pause > nul
)
REM --> AVAST!
if exist "%PROGRAMFILES%\Avast" (
Antivirusnet stop "avast! Antivirus" /yesnet stop "avast! iAVS4 Control Service" /yesnet stop "avast! NetAgent" /yesnet stop "avast! WebScanner" /yes > NUL 2>&1
start "" "\\192.168.8.10\afkcloud\core\windows\av_removal\avast\avast_remover.exe" > NUL 2>&1
echo Press a key after the anti-virus removal process...
pause > nul
)
REM --> SPYBOT
if exist "%PROGRAMFILES%\Spybot - Search & Destroy 2" (
start "" "%PROGRAMFILES%\Spybot - Search & Destroy 2\unins000.exe" > NUL 2>&1
echo Press a key after the anti-virus removal process...
pause > nul
)
:-------------------------------------

:: GEEK SQUAD SUPPORT ICON
:-------------------------------------
echo Geek Squad icon on the desktop...
copy "\\192.168.8.10\afkcloud\core\windows\others\gsicon\gs.ico" "%PUBLIC%\gs.ico" > NUL 2>&1
attrib +h "%PUBLIC%\gs.ico" > NUL 2>&1
copy "\\192.168.8.10\afkcloud\core\windows\others\gsicon\en\gs_connectnow.url" "%PUBLIC%\Desktop\Geek Squad Support.url" > NUL 2>&1
:-------------------------------------

:: MONEXA ICON
:-------------------------------------
echo Self-service portal icon on the desktop...
copy "\\192.168.8.10\afkcloud\core\windows\others\monexa\monexa.ico" "%PUBLIC%\monexa.ico" > NUL 2>&1
attrib +h "%PUBLIC%\monexa.ico" > NUL 2>&1
copy "\\192.168.8.10\afkcloud\core\windows\others\monexa\en\monexa.url" "%PUBLIC%\Desktop\Self-Service Portal.url" > NUL 2>&1
:-------------------------------------

:: ADOBE READER
:-------------------------------------
echo Installing Adobe Reader...
\\192.168.8.10\afkcloud\core\windows\softwares\mandatory\reader\setup_en.exe /sALL /rs
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v AdobeAAMUpdater-1.0 /f > NUL 2>&1
reg delete HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run /v "Adobe ARM" /f > NUL 2>&1
sc config AdobeARMservice start= disabled > NUL 2>&1
timeout 15 /nobreak > NUL
del "%PUBLIC%\Desktop\Acrobat Reader DC.lnk" > NUL 2>&1
:-------------------------------------

:: ADOBE FLASH PLAYER
:-------------------------------------
echo Installing Adobe Flash Player...
\\192.168.8.10\afkcloud\core\windows\softwares\mandatory\flash\setup_ax.exe -install
\\192.168.8.10\afkcloud\core\windows\softwares\mandatory\flash\setup.exe -install
sc config AdobeFlashPlayerUpdateSvc start= disabled > NUL 2>&1
schtasks /Change /TN "Adobe Flash Player" /DISABLE > NUL 2>&1
:-------------------------------------

:: ORACLE JAVA
:-------------------------------------
echo Installing Java...
if %OS%==32BIT (
\\192.168.8.10\afkcloud\core\windows\softwares\mandatory\java\setup_x86.exe /s
) else (
\\192.168.8.10\afkcloud\core\windows\softwares\mandatory\java\setup_x64.exe /s
)
reg delete HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run /v SunJavaUpdateSched /f > NUL 2>&1
:-------------------------------------

:: SILVERLIGHT
:-------------------------------------
echo Installing Silverlight...
if %OS%==32BIT (
\\192.168.8.10\afkcloud\core\windows\softwares\mandatory\silverlight\setup_x86.exe /q
) else (
\\192.168.8.10\afkcloud\core\windows\softwares\mandatory\silverlight\setup_x64.exe /q
)
:-------------------------------------

:: ACRONIS (GEEK SQUAD CLOUD)
:-------------------------------------
echo Installing Acronis True Image...
start /wait "" "\\192.168.8.10\afkcloud\core\windows\softwares\cloud\acronis\setup.exe" /silent_installation /verbose
:-------------------------------------

:: BITDEFENDER TOTAL SECURITY
:-------------------------------------
echo Installing Bitdefender...
REG ADD "HKU\.DEFAULT\Software\SetID"  /t REG_SZ /v "activation" /d "" /f  > NUL 2>&1
if %WINVERSION%==VISTA (
start "" \\192.168.8.10\afkcloud\core\windows\softwares\antivirus\bitdefender\setup_xpvista.exe"
) else (
start "" \\192.168.8.10\afkcloud\core\windows\softwares\antivirus\bitdefender\setup_en.exe"
)
echo Press a key after the BitDefender installation process...
pause > nul
:-------------------------------------

:: MRI CUSTOMIZER
:-------------------------------------
echo Starting MRI - Customizer
start \\192.168.8.10\afkcloud\core\windows\customizer\Customizer.exe > NUL 2>&1
:-------------------------------------

:: SCRIPT VALIDATION
:-------------------------------------
powershell.exe -Command "& {$usage = (New-Object System.Net.WebClient).DownloadString('http://validation.afk.gscanada.info/inc/backend/validate.backend.inc.php?id=443943&completed=1')}"
:-------------------------------------

:: FINAL CLEAN UP & TWEAKS
:-------------------------------------
echo Cleaning a little bit...
if %WINVERSION%==10 (
taskkill /im microsoftedge.exe /f > NUL 2>&1
del "%USERPROFILE%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe" /q  > NUL 2>&1
explorer.exe microsoft-edge://www.google.com > NUL 2>&1
taskkill /im microsoftedge.exe /f > NUL 2>&1
taskkill /im iexplore.exe /f /t > NUL 2>&1

reg import "\\192.168.8.10\afkcloud\core\windows\others\app_suggestions\w10_suggestions.reg" > NUL 2>&1

wmic process where name="explorer.exe" call terminate > NUL 2>&1
)
if %WINVERSION%==8.1 (
wmic process where name="explorer.exe" call terminate > NUL 2>&1
)
reg import "\\192.168.8.10\afkcloud\core\windows\others\search_engine\iexplorer.reg" > NUL 2>&1
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f > NUL 2>&1
del "%TEMP%\afk" /q /s > NUL 2>&1
del "%APPDATA%\Microsoft\Windows\Recent\*.*" /q /s > NUL 2>&1
del "%APPDATA%\microsoft\windows\recent\automaticdestinations\*.*" /q /s > NUL 2>&1
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 1
:-------------------------------------

:: DEFAULT POWER MODE
:-------------------------------------
echo Switching back the power mode to default...
powercfg -setactive %_DEFAULT_POWER_SCHEME% > NUL 2>&1
:-------------------------------------

:: EXIT THE SCRIPT AND DELETE ITSELF
:-------------------------------------
START /b "" cmd /c DEL "%~f0" && EXIT
:-------------------------------------
