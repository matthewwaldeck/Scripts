<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-26-2018
    Language:   PowerShell
    Purpose:    Automates basic setup steps for a new Windows PC.
    Last Edit:  08-13-2019
    Version:    v0.2.1 (Testing required)

    TASKS:
    -Create log
    -Set power mode to High Performance
    -Ensure temp file exists
    -Download and install software
        -Google Chrome
        -Spotify
        -Visual Studio Code
    -Clean up temp file
    -Set power mode to Balanced
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

function rename {
    $comp_name =  Read-Host "Enter desired computer name..."
    Rename-Computer -NewName $comp_name
}

function download {
    #Google Chrome
    try {
        Write-Host "Downloading Google Chrome..."
        (New-Object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', 'C:\temp\GoogleChrome.exe')
        "Downloaded Google Chrome." | Add-Content -Path $logPath
        "Success!"
        Write-Host ''
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
        "Downloaded Spotify." | Add-Content -Path $logPath
        Write-Host "Success!"
        Write-Host ''
    } Catch {
        Write-Host "Spotify failed to download!"
        "Spotify failed to download!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }

    #Visual Studio Code
    try {
        Write-Host "Downloading Visual Studio Code..."
        (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/win32-x64-user-stable', 'C:\temp\VS_Code.exe')
        "Downloaded Visual Studio Code." | Add-Content -Path $logPath
        Write-Host "Success!"
        Write-Host ''
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
    #Deleted temp files.
    Write-Host "Cleaning up..."
    Remove-Item C:\temp -rec
    "Removed temp files." | Add-Content -Path $logPath
}

# SCRIPT #
"Setup started at $(Get-TimeStamp) by $env:UserName" | Set-Content -Path $logPath
'' | Add-Content -Path $logPath
$setup = Read-Host "Would you like to install the default power plans? (y/n)"

tempCheck
rename
if ($setup -eq "y") {
    "Setup initiated..." | Add-Content -Path $logPath
    download
    setup
}
cleanup

'' | Add-Content -Path $logPath
"Setup completed at $(Get-TimeStamp)" | Add-Content -Path $logPath
Write-Host ''
Write-Host "Setup complete - Your PC will now restart."
Restart-Computer