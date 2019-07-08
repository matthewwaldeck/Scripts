<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-08-2018
    Language:   PowerShell
    Purpose:    Downloads and installs basic software onto a new PC.
    Last Edit:  07-08-2019
    Version:    v3.0.0

    NOTE:
    This will replace the C# version of AutoPilot, as this is more efficient and easier to maintain.
#>

# Download & install Google Chrome
$Path = $env:TEMP; $Installer = "chrome_installer.exe"; Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Path\$Installer; Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; Remove-Item $Path\$Installer

# Download & install Spotify
$Path = $env:TEMP; $Installer = "spotify_installer.exe"; Invoke-WebRequest "https://www.spotify.com/ca-en/download/" -OutFile $Path\$Installer; Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; Remove-Item $Path\$Installer

# Download & install Visual Studio Code
$Path = $env:TEMP; $Installer = "code_installer.exe"; Invoke-WebRequest "https://code.visualstudio.com/Download#" -OutFile $Path\$Installer; Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; Remove-Item $Path\$Installer