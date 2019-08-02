<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-26-2018
    Language:   PowerShell
    Purpose:    Downloads and installs software on a new computer.
    Last Edit:  08-02-2019
    Version:    v0.2.0 (Testing required)

    TASKS:
    -Log all tasks
    -Install software
        -Google Chrome
        -Spotify
        -Visual Studio Code
    -Set up power options
#>

$logPath = "C:\Users\$env:UserName\Desktop\setup_$(get-date -f yyyy-MM-dd-HHmm).log" #Log file destination

# FUNCTIONS #
function Get-TimeStamp {
    return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
}

function enablePower {
    #Ensures all default Windows power plans are present, with the exception of Ultimate.
    powercfg.exe -duplicatescheme a1841308-3541-4fab-bc81-f71556f20b4a
    Write-Host "Power plan 'Power Saving' added."
    powercfg.exe -duplicatescheme 381b4222-f694-41f0-9685-ff5bb260df2e
    Write-Host "Power plan 'Balanced' added."
    powercfg.exe -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    Write-Host "Power plan 'High Performance' added."
    <#powercfg.exe -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    Write-Host "Power plan 'Ultimate Performance' added."#>
}

function setPower {
    #Sets Windows power option to prevent sleep and increase performance (in theory).
    Try {
        "Setting power plan to High Performance..."
        $HighPerf = powercfg -l | ForEach-Object{if($_.contains("High performance")) {$_.split()[3]}}
        $CurrPlan = $(powercfg -getactivescheme).split()[3]
        if ($CurrPlan -ne $HighPerf) {powercfg -setactive $HighPerf}
        "Power Plan set to High Performance." | Add-Content -Path $logPath
    } Catch {
        Write-Warning -Message "Unable to set power plan to high performance"
    }
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

    #Virual Studio Code
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

    #Resets Windows power option back to Balanced.
    Try {
        "Setting power plan to Balanced..."
        $BalPerf = powercfg -l | ForEach-Object{if($_.contains("Balanced")) {$_.split()[3]}}
        $CurrPlan = $(powercfg -getactivescheme).split()[3]
        if ($CurrPlan -ne $BalPerf) {powercfg -setactive $BalPerf}
        "Power Plan set to Balanced." | Add-Content -Path $logPath
    } Catch {
        Write-Warning -Message "Unable to set power plan to Balanced"
    }
}

# SCRIPT #
"Setup started at $(Get-TimeStamp) by $env:UserName" | Set-Content -Path $logPath
'' | Add-Content -Path $logPath

#$power = Read-Host "Would you like to install the default power plans? (y/n)"
if ($power -eq "y") {
    enablePower
}

setPower
tempCheck
download
#setup
cleanup
'' | Add-Content -Path $logPath
"Setup completed at $(Get-TimeStamp)" | Add-Content -Path $logPath
Write-Host ''