<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-26-2018
    Language:   PowerShell
    Purpose:    Automates the basic setup process for a new Windows PC.
    Last Edit:  12-20-2019
    Version:    1.0.0

    TASKS:
    -Create log file
    -Rename the computer
    -Ensure temp file exists
    -Download and install Chrome and Spotify
    -Clean up temp file
    -Optimize all attached drives
    -Reboot the computer

    TO-DO:
    -Power modes
    -Clean up taskbar & start menu
    -Set defaults
#>

$logPath = "C:\Users\$env:UserName\Desktop\setup_$(get-date -f yyyy-MM-dd-HHmm).log" #Log file destination


# FUNCTIONS #
function Get-TimeStamp {
    return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
}

function rename {
    $comp_name =  Read-Host "Enter desired computer name..."
    Rename-Computer -NewName $comp_name
    Write-Host "Computer name set to $comp_name."
    "$(Get-TimeStamp) - Computer name set to $comp_name." | Add-Content -Path $logPath
}

function tempCheck {
    #Check for existence of temp file
    $tempCheck = Test-Path C:\temp
    if ($tempCheck -eq $False) {
        New-Item -Path "C:\temp\" -ItemType Directory | Out-Null
        "$(Get-TimeStamp) - Created C:\temp" | Add-Content -Path $logPath
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
        "$(Get-TimeStamp) - Google Chrome failed to download!" | Add-Content -Path $logPath
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
        "$(Get-TimeStamp) - Spotify failed to download!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }
}

function install {
    try {
        Write-Host "Installing Google Chrome..."
        C:\temp\GoogleChrome.exe /silent /install
        Write-Host "Google Chrome has been installed!"
        "$(Get-TimeStamp) - Successfully installed Google Chrome!" | Add-Content -Path $logPath
    } Catch {
        Write-Host "Failed to install Google Chrome!"
        "$(Get-TimeStamp) - Failed to install Google Chrome!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }

    try {
        Write-Host "Installing Spotify..."
        C:\temp\Spotify.exe /silent /install
        Write-Host "Spotify has been installed!"
        "$(Get-TimeStamp) - Successfully installed Spotify!" | Add-Content -Path $logPath
    } Catch {
        Write-Host "Failed to install Spotify!"
        "$(Get-TimeStamp) - Failed to install Spotify!" | Add-Content -Path $logPath
        $_ | Add-Content -Path $logPath
        '' | Add-Content -Path $logPath
    }
}

function cleanup {
    #Deleted temp files.
    Write-Host "Cleaning up..."
    Remove-Item C:\temp -rec
    "$(Get-TimeStamp) - Removed temp files." | Add-Content -Path $logPath
}

function optimize {
    if ($optimize -eq "y"){
        "Optimizing and Defragging drives..."
        "$(Get-TimeStamp) - Beginning defrag on disks..." | Add-Content -Path $logPath
        $Disks=Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
        ForEach ($Disk in $Disks) {
            "$(Get-TimeStamp) - Beginning defrag on $Disk." | Add-Content -Path $logPath
            defrag $Disk /O | Out-Null
            "$(Get-TimeStamp) - Completed defrag on $Disk." | Add-Content -Path $logPath
        }
    }
}

function fin {
    '' | Add-Content -Path $logPath
    "Setup completed at $(Get-TimeStamp)" | Add-Content -Path $logPath
    Write-Host ''
    if ($reboot -eq "y") {
        Write-Host "Setup complete! Your PC will now restart..."
        "$(Get-TimeStamp) - Restarting computer." | Add-Content -Path $logPath
        Start-Sleep -Seconds 5
        Restart-Computer
    } else {
        Write-Host "Setup complete!"
        Start-Sleep -Seconds 5
        exit
    }
}

# SCRIPT #
"Setup started at $(Get-TimeStamp) by $env:UserName" | Set-Content -Path $logPath
'' | Add-Content -Path $logPath

#Set flags before beginning.
$setup = Read-Host "Would you like to install Google Chrome and Spotify? (y/n)"
$optimize = Read-Host "Would you like to defrag any attached drives? (y/n)"
$reboot = Read-Host "Would you like to reboot your PC upon completion? (y/n)"

rename #Rename the PC, depenting on user input.
tempCheck #Ensure temp folder exists.

#Download and install some basic programs.
if ($setup -eq "y") {
    Write-Host "Beginning installation of programs..."
    "$(Get-TimeStamp) - Beginning installation of programs..." | Add-Content -Path $logPath
    download
    install
} else {
    Write-Host "Programs will not be installed."
    "$(Get-TimeStamp) - Programs will not be installed." | Add-Content -Path $logPath
}

cleanup #Clean up the temp folder.
optimize #Optimize all drives, if requested.
fin #Reboot the computer or close session, depending on flag.