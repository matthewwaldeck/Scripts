<#
    DESCRIPTION
    Author:     Matt Waldeck
    Created:    07-26-2019
    Purpose:    Automates the basic setup process for a new Windows PC.
    Version:    0.4.0

    TASKS:
    -Create a log file
    -Rename the computer
    -Offer to join a Domain
    -Offer to add network printers
    -Offer to install some programs
    -Clean up bloat and temp files
    -Offer to reboot computer
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
        "Downloading $program_name..." | Add-Content -Path $path_log
        (New-Object System.Net.WebClient).DownloadFile($url_download, $output)
        Write-Host "Download complete! Running install file..."
        "Download complete! Installing..." | Add-Content -Path $path_log
        Start-Process $output "/S"
        Write-Host "$program_name has been installed successfully!"
        "$program_name has been installed!" | Add-Content -Path $path_log
    } catch [System.Net.WebException] {
        #Download failed.
        Write-Host "$program_name failed to download!"
        "$program_name failed to download!" | Add-Content -Path $path_log
        $_ | Add-Content -Path $path_log
    } catch {
        #Installation failed.
        Write-Host '$program_name failed to install!'
        "$program_name failed to install!" | Add-Content -Path $path_log
        $_ | Add-Content -Path $path_log
    }
    Remove-Item -path "$env:SystemDrive\temp\$program_name"
}


# ARRAYS AND VARIABLES #
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
$arr_bloat = @('3dbuilder','getstarted','officehub','skypeapp','solitairecollection','zunemusic','zunevideo')
$arr_install = @('Reader','Firefox','GitHub','Spotify','VSCode','VLC')
$url_adobe = "https://get.adobe.com/reader/download/?installer=Reader_DC_2020.006.20034_English_for_Windows&os=Windows%2010&browser_type=KHTML&browser_dist=Chrome&dualoffer=false&mdualoffer=true&stype=7491&d=McAfee_Security_Scan_Plus&d=McAfee_Safe_Connect"
$url_firefox = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
$url_github = "https://central.github.com/deployments/desktop/desktop/latest/win32"
$url_spotify = "https://download.scdn.co/SpotifySetup.exe"
$url_vscode = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
$url_vlc = "https://get.videolan.org/vlc/3.0.11/win64/vlc-3.0.11-win64.exe"


# SCRIPT #
#Create log file for troubleshooting.
"$(Get-TimeStamp) - Setup started by $env:UserName" | Set-Content -Path $path_log

#Make sure temp folder exists on system drive.
if (Test-Path -Path $path_temp -eq $false) {
    New-Item -Path $path_temp -ItemType Directory | Out-Null
    Write-Host "Created temp directory."
    "Created temp directory!" | Add-Content -Path $path_log
} else {
    Write-Host "Temp directory already present!"
    "Temp directory already present!" | Add-Content -Path $path_log
}

#Rename the computer.
if (Test-Path -Path $path_rename -eq $false) {
    $comp_name =  Read-Host "Enter desired computer name, or press enter to continue."
    if ($comp_name -ne ""){
        Rename-Computer -NewName $comp_name
        "Computer name has been set!" | Add-Content -Path $path_rename
        Write-Host "Computer name set to $comp_name."
        "$(Get-TimeStamp) - Computer name set to $comp_name." | Add-Content -Path $path_log
    }
}

#Add the computer to a domain.
if ($domain_current.Name -eq ""){
    $domain_join = Read-Host "Would you like to join a domain?"
    if ($domain_join.ToLower() -eq "yes"){
        $domain_new = Read-Host "What is the domain name?"
        try {
            Add-Computer -DomainName $domain_new
            "$(Get-TimeStamp) - Successfully joined $domain_new. Rebooting computer..." | Add-Content -Path $path_log
            "Successfully joined $domain_new. Your computer will now reboot. Please rerun script to continue setup."
            Restart-Computer
        } catch {
            Write-Host "Failed to join $domain_new"
            "$(Get-TimeStamp) - Failed to join $domain_new." | Add-Content -Path $path_log
            $_ | Add-Content -Path $path_log
            exit
        }
    } else {
        Write-Host "Declined to join domain."
        "$(Get-TimeStamp) - Declined to join domain." | Add-Content -Path $path_log
    }
}

#Install network printers.
$print_ask = Read-Host "Would you like to add a network printer?"
$print_ask = $print_ask.ToLower()
if ($print_ask -eq "yes") {
    $print_server = Read-Host "where is your print server?"
    try{
        Invoke-Item -Path $print_server
    } Catch {
        Write-Host "Failed to add printers!"
        "$(Get-TimeStamp) - Failed to add printers." | Add-Content -Path $path_log
    }
} else {
    "$(Get-TimeStamp) - No printers added." | Add-Content -Path $path_log
}

#Installs applications, based on user input. 
do {
    Write-Host ""
    $install = Read-Host "Would you like to install some basic software?"
    $install = $install.ToLower()
    if ($install -eq 'yes') {
        do {
            Clear-Host
            foreach ($i in $arr_install) {
                Write-Host "-$i`n"
            }
            $app = Read-Host "What would you like to install?"
            switch ($app.ToLower()) {
                reader {install_programs "$url_adobe" "Adobe Reader"}
                firefox {Install_Programs "$url_firefox" "Firefox"}
                github {Install_Programs "$url_github" "GitHub Desktop"}
                spotify {Install_Programs "$url_spotify" "Spotify"}
                vscode {Install_Programs "$url_vscode" "Visual Studio Code"}
                vlc {Install_Programs "$url_vlc" "VLC Media Player"}
                Default {Write-Host "Please choose from the applications listed, or type done."}
            }
        } until ($app -eq 'done')
    } elseif ($install -eq 'no') {
        Write-Host "Nothing has been installed."
        "$(Get-TimeStamp) - No programs were installed." | Add-Content -Path $path_log
    } else {
        Write-Host "Please make a valid selection."
    }
} until ($install -eq "yes" -or $install -eq "no")

#Remove some preinstalled apps
"$(Get-TimeStamp) - Beginning cleanup..." | Add-Content -Path $path_log
foreach ($i in $arr_bloat) {
    try {
        Get-AppxPackage *$i* | Remove-AppxPackage
        "$(Get-TimeStamp) - $i has been removed." | Add-Content -Path $path_log
    } catch {
        "$(Get-TimeStamp) - Failed to remove $i." | Add-Content -Path $path_log
    }
}
Remove-Item -path $path_rename #Remove renaming flag from temp folder.
cleanmgr.exe | Out-Null #Run Disk Cleanup, wait until closed to continue.

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