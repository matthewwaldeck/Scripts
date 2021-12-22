<#
    DESCRIPTION
    Author:     Matt Waldeck
    Created:    07-26-2019
    Purpose:    Automates the basic setup process for a new Windows PC.
    Version:    0.3.0

    TASKS:
    -Create a log file
    -Rename the computer
    -Join a Domain
    -Add network printers
    -Install some basic programs
    -Clean up
    -Ask to reboot computer
#>


# FUNCTIONS #
function Get-TimeStamp {
    <# This function simply returns a timestamp of the current date and time.
    It's used in the logs so I can see if something is taking too long. #>
    return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
}

function Install_Programs ($url_download, $program_name) {
    #Downloads and installs the selected software package.
    $output = "$env:SystemDrive\temp\$program_name.exe"
    try {
        Write-Host "Downloading $program_name..."
        "Downloading $program_name..." | Set-Content -Path $path_log
        (New-Object System.Net.WebClient).DownloadFile($url_download, $output)
        Write-Host "Download complete! Running install file..."
        "Download complete! Installing..." | Set-Content -Path $path_log
        Start-Process $output "/S"
        Write-Host "$program_name has been installed successfully!"
        "$program_name has been installed!" | Set-Content -Path $path_log
    } catch [System.Net.WebException] {
        #Download failed.
        Write-Host "$program_name failed to download!"
        "$program_name failed to download!" | Set-Content -Path $path_log
        $_ | Set-Content -Path $path_log
    } catch {
        #Installation failed.
        Write-Host '$program_name failed to install!'
        "$program_name failed to install!" | Set-Content -Path $path_log
        $_ | Set-Content -Path $path_log
    }
}


# VARIABLES #
$disks = Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
$domain_current = Get-ADDomain -Current LocalComputer
$domain_new = ""
$domain_join = ""
$install = ""
$path_log = "C:\Users\$env:UserName\Desktop\setup_$(get-date -f yyyy-MM-dd-HHmm).log"
$path_temp = "$env:SystemDrive\temp"
$path_rename = "$env:SystemDrive\temp\rename.flag"
$print_ask = ""
$print_server = ""
$url_adobe = "https://get.adobe.com/reader/download/?installer=Reader_DC_2020.006.20034_English_for_Windows&os=Windows%2010&browser_type=KHTML&browser_dist=Chrome&dualoffer=false&mdualoffer=true&stype=7491&d=McAfee_Security_Scan_Plus&d=McAfee_Safe_Connect"
$url_firefox = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
$url_github = "https://central.github.com/deployments/desktop/desktop/latest/win32"
$url_spotify = "https://download.scdn.co/SpotifySetup.exe"
$url_vscode = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
$url_vlc = "https://get.videolan.org/vlc/3.0.11/win64/vlc-3.0.11-win64.exe"


# SCRIPT #
#Create logfile for troubleshooting.
"$(Get-TimeStamp) - Setup started by $env:UserName" | Set-Content -Path $path_log

#Make sure temp folder exists on system drive.
if (Test-Path -Path $path_temp -eq $false) {
    New-Item -Path $path_temp -ItemType Directory | Out-Null
    Write-Host "Created temp directory."
    "Created temp directory!" | Set-Content -Path $path_log
} else {
    Write-Host "Temp directory already present!"
    "Temp directory already present!" | Set-Content -Path $path_log
}

#Rename the computer.
if (Test-Path -Path $path_rename -eq $false) {
    $comp_name =  Read-Host "Enter desired computer name, or press enter to continue."
    if ($comp_name -ne ""){
        Rename-Computer -NewName $comp_name
        "Computer name has been set!" | Set-Content -Path $path_rename
        Write-Host "Computer name set to $comp_name."
        "$(Get-TimeStamp) - Computer name set to $comp_name." | Add-Content -Path $path_log
    }
}

#Add the computer to a domain.
if ($domain_current.Name -eq ""){
    $domain_join = Read-Host "Would you like to join a domain?"
    if ($domain_join -eq "yes"){
        $domain_new = Read-Host "What is the domain name?"
        try {
            Add-Computer -DomainName $domain_new
            "$(Get-TimeStamp) - Successfully joined $domain_new. Rebooting computer..." | Add-Content -Path $path_log
            "Successfully joined $domain_new. Your computer will now reboot. Please rerun script to continue setup."
            Restart-Computer
        } catch {
            Write-Host "Failed to join $domain_new"
            "$(Get-TimeStamp) - Failed to join $domain_new." | Add-Content -Path $path_log
            $_ | Set-Content -Path $path_log
            exit
        }
    }
}

#Install network printers.
$print_ask = Read-Host "Would you like to add a network printer?"
$print_ask = $print_ask.ToLower()
if ($print_ask -eq "yes") {
    $print_server = Read-Host "where is your print server?"
    Invoke-Item -Path $print_server
}

#This needs to be updated. See below.
do {
    Write-Host ""
    $install = Read-Host "Would you like to install some basic software?"
    $install = $install.ToLower()
    if ($install -eq 'yes') {
        install_programs "$url_adobe" "Adobe Reader"
        Install_Programs "$url_firefox" "Firefox"
        Install_Programs "$url_github" "GitHub Desktop"
        Install_Programs "$url_spotify" "Spotify"
        Install_Programs "$url_vscode" "Visual Studio Code"
        Install_Programs "$url_vlc" "VLC Media Player"
    } elseif ($install -eq 'no') {
        Write-Host "Nothing has been installed."
        "No programs were installed." | Add-Content -Path $path_log
    } else {
        Write-Host "Please make a valid selection."
    }
} until ($install -eq "yes" -or $install -eq "no")

#Clean up temp folder.
Remove-Item -path "$env:SystemDrive\temp\Adobe Reader.exe"
Remove-Item -path "$env:SystemDrive\temp\Firefox.exe"
Remove-Item -path "$env:SystemDrive\temp\GitHub Desktop"
Remove-Item -path "$env:SystemDrive\temp\Spotify"
Remove-Item -path "$env:SystemDrive\temp\Visual Studio Code"
Remove-Item -path "$env:SystemDrive\temp\VLC Media Player"
Remove-Item -path $path_rename

#Remove some preinstalled apps
Get-AppxPackage *3dbuilder* | Remove-AppxPackage #3D Builder
Get-AppxPackage *getstarted* | Remove-AppxPackage #Get Started
Get-AppxPackage *officehub* | Remove-AppxPackage #Get Office
Get-AppxPackage *skypeapp* | Remove-AppxPackage #Get Skype
Get-AppxPackage *solitairecollection* | Remove-AppxPackage #Solitaire Collection
Get-AppxPackage *zunemusic* | Remove-AppxPackage #Groove Music
Get-AppxPackage *zunevideo* | Remove-AppxPackage #Movies & TV

#Run Disk Cleanup, wait until closed to continue.
cleanmgr.exe | Out-Null

#Optimize all attached disks.
Write-Host "Beginning disk optimization..."
"$(Get-TimeStamp) - Beginning disk optimization..." | Add-Content -Path $path_log
ForEach ($disk in $disks) {
    "$(Get-TimeStamp) - Beginning defrag on $disk." | Add-Content -Path $path_log
    defrag $disk /O | Out-Null
    "$(Get-TimeStamp) - Completed defrag on $disk." | Add-Content -Path $path_log
}
Write-Host "Disk optimization complete!"
"$(Get-TimeStamp) - Disk optimization complete!" | Add-Content -Path $path_log

#Finish up
Write-Host "Setup complete!"
"$(Get-TimeStamp) - Setup completed!" | Add-Content -Path $path_log
$reboot = Read-Host "Would you like to reboot this computer?"
$reboot = $reboot.ToLower()
if ($reboot -eq "yes"){
    Write-Host "Restarting your PC..."
    "$(Get-TimeStamp) - Restarting computer." | Add-Content -Path $path_log
    Start-Sleep -Seconds 5
    Restart-Computer
} else {
    Start-Sleep -Seconds 5
    exit
}