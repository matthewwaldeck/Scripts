<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-26-2018
    Language:   PowerShell
    Purpose:    Downloads and installs software on a new computer.
    Last Edit:  07-26-2019
    Version:    v0.1.1

    TASKS:
    -Log all tasks
    -Download, install, and clean up software
    -Set sleep and power options (Coming Soon)
#>

$logPath = "C:\Users\$env:UserName\Desktop\setup_$(get-date -f yyyy-MM-dd-HHmm).log" #Log file destination

# FUNCTIONS #
function Get-TimeStamp {
    return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
  }

function tempCheck {
    #Check for existence of temp file
    $tempCheck = Test-Path C:\temp
    if ($tempCheck -eq $False) {
        New-Item -Path "C:\temp\" -ItemType Directory | Out-Null
        "Created C:\temp" | Add-Content -Path $logPath
        Write-Host "Created temp file."
    }
}

function download {
    #Google Chrome
    try {
        Write-Host "Downloading Google Chrome..."
        (New-Object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', 'C:\temp\GoogleChrome.exe')
    } Catch {
        Write-Host "Google Chrome failed to download!"
        "Google Chrome failed to download!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }

    #Spotify
    try {
        Write-Host "Downloading Spotify..."
        (New-Object System.Net.WebClient).DownloadFile('https://download.scdn.co/SpotifySetup.exe', 'C:\temp\Spotify.exe')
    } Catch {
        Write-Host "Spotify failed to download!"
        "Spotify failed to download!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }

    #Virual Studio Code
    try {
        Write-Host "Downloading Visual Studio Code..."
        (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/win32-x64-user-stable', 'C:\temp\VS_Code.exe')
    } Catch {
        Write-Host "Virtual Studio Code failed to download!"
        "Virtual Studio Code failed to download!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }
}

function setup {
    try {
        Write-Host "Installing Google Chrome..."
        C:\temp\GoogleChrome.exe /silent /install
        Write-Host "Google Chrome has been installed!"
        "$(Get-TimeStamp) - Successfully installed Google Chrome!" | Add-Content -Path $logPath
    } Catch {
        "Failed to install Google Chrome!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }

    try {
        Write-Host "Installing Spotify..."
        C:\temp\Spotify.exe /silent /install
        Write-Host "Spotify has been installed!"
        "$(Get-TimeStamp) - Successfully installed Spotify!" | Add-Content -Path $logPath
    } Catch {
        "Failed to install Spotify!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }

    try {
        Write-Host "Installing Visual Studio Code..."
        C:\temp\VS_Code.exe /silent /install
        Write-Host "Visual Studio Code has been installed!"
        "$(Get-TimeStamp) - Successfully installed Visual Studio Code!" | Add-Content -Path $logPath
    } Catch {
        "Failed to install Visual Studio Code!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }
}

function cleanup {
    Write-Host "Cleaning up..."
    Remove-Item C:\temp -rec
}

# SCRIPT #
"Setup started at $(Get-TimeStamp) by $env:UserName" | Add-Content -Path $logPath
tempCheck
download
#setup
cleanup
"Setup completed at $(Get-TimeStamp)" | Add-Content -Path $logPath
Write-Host ''