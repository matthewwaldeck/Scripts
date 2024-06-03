<#
    .NOTES        
        NAME:    setup.ps1
        AUTHOR:  Matt Waldeck
        VERSION: 0.6.0
        DATE:    2024/06/03
        LINK:    https://github.com/Gediren/Windows-Scripts/blob/master/Automation/setup.ps1

        VERSION HISTORY
            0.4.0 - 2019.07.26
                Major cleanup.
                Working on making the code more ambiguous.
            0.5.0 - 2023.12.06
                Updated documentation to use get-help syntax.
                Improved comments and readability.
                Merged console and logging into procedure to cut out repetitive code.
                General usability & readability improvements.
            0.6.0 - 2024.06.03
                Added more Microsoft AppX packages to cleanup.
                Added antivirus removal to cleanup.
                Increased readability of section titles.
    
    .SYNOPSIS
        Set up a new Windows computer.

    .DESCRIPTION
        This script will get a lot of the basic setup completed on a new Windows PC.
        It can install applications, clean up some preinstalled junk, and more.
        It dumps a log when done for troubleshooting in case of issue.
        This script remains untested and under development for the time being.
        Once tested, it will get a full release.

    .INPUTS
        None. You cannot pipe objects to this script.

    .OUTPUTS
        A log file on the current user's desktop.

    .LINK
        https://github.com/mattwaldeck/
#>




#####################
##### FUNCTIONS #####
#####################
function Log ($comment) {
    #This function writes output to the console, and writes the same line to the logfile.
    #It will append the date and time to the beginning of the log entry.
    $timestamp = "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
    Write-Host "$comment"
    "$timestamp - $comment" | Add-Content -Path $path_log
}

function Install ($url_download, $program_name) {
    #Downloads and installs the selected software package.
    #Input comes from loop and array down below.
    
    $output = "$env:SystemDrive\temp\$program_name.exe"

    try {
        Log "Downloading $program_name..."
        (New-Object System.Net.WebClient).DownloadFile($url_download, $output)
        Log "Download complete! Running install file..."
        Start-Process $output "/S"
        Log "$program_name has been installed successfully!"
    } catch [System.Net.WebException] {
        #Download failed.
        Log "$program_name failed to download!"
        Log $_
    } catch {
        #Installation failed.
        Log "$program_name failed to install!"
        Log $_
    }
}




################################
##### ARRAYS AND VARIABLES #####
################################

#Constants
$arr_ms_bloat = @('3d','getstarted','gethelp','officehub','skypeapp','solitairecollection','zunemusic','zunevideo')
$arr_install = @('Reader','Firefox','GitHub', 'Notepad++','Spotify','VSCode','VLC')
$disks = Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
$domain_current = Get-ADDomain -Current LocalComputer
$path_log = "C:\Users\$env:UserName\Desktop\setup_$(get-date -f yyyy-MM-dd-HHmm).log"
$path_rename = "$env:SystemDrive\temp\rename.flag"
$path_temp = "$env:SystemDrive\temp"

#Variables
$domain_join = ""
$domain_new = ""
$enterprise = ""
$install = ""
$print_ask = ""
$print_server = ""

#Download URLs for programs.
$url_adobe = "https://get.adobe.com/reader/download?os=Windows+11&name=Reader+2023.006.20380+English+for+Windows&lang=en&nativeOs=Windows+10&accepted=&declined=&preInstalled=&site=enterprise"
$url_firefox = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
$url_github = "https://central.github.com/deployments/desktop/desktop/latest/win32"
$url_notepad = "https://notepad-plus-plus.org/downloads/v8.6/"
$url_spotify = "https://download.scdn.co/SpotifySetup.exe"
$url_vscode = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
$url_vlc = "https://get.videolan.org/vlc/3.0.20/win32/vlc-3.0.20-win32.exe"




##########################
##### HARDWARE CHECK #####
##########################
$cpu = Get-WMIObject -Class Win32_Processor | Select-Object name
$memory = [math]::Round($system.TotalPhysicalMemory / 1GB,1) + 'GB'
Write-Host "CPU: $cpu" 
Write-Host "Memory: $memory"
foreach ($_ in $storage) {
    'Drive: ' + $_.DeviceID + '\'
    if ($_.VolumeName -ne '') {
    'Name: ' + $_.VolumeName
    }
    'Capacity: ' + [math]::Round($_.Size / 1GB,2) + 'GB'
    'Used: ' + [math]::Round(($_.Size - $_.FreeSpace) / 1GB,2) + 'GB'
    'Free: ' + [math]::Round($_.FreeSpace / 1GB,2) + 'GB'
    ''
}
Write-Host "Close this window to cancel, or"
Pause




#################
##### SETUP #####
#################

#Create log file for troubleshooting.
Log "Setup started by $env:UserName" | Set-Content -Path $path_log
Write-Host

#Close browsers.
taskkill /im microsoftedge.exe /f > NUL 2>&1
taskkill /im iexplore.exe /f > NUL 2>&1
taskkill /im chrome.exe /f > NUL 2>&1
taskkill /im firefox.exe /f > NUL 2>&1
taskkill /im opera.exe /f > NUL 2>&1

#Make sure temp folder exists on system drive.
if (Test-Path -Path $path_temp -eq $false) {
    #Create new temp folder.
    New-Item -Path $path_temp -ItemType Directory | Out-Null
    Log "Created temp directory."
} else {
    #Temp folder already exists.
    Log "Temp directory already present!"
}

#Rename the computer.
if (Test-Path -Path $path_rename -eq $false) {
    Write-Host
    $comp_name =  Read-Host "Enter desired computer name, or press enter to continue."
    if ($comp_name -ne ""){
        Rename-Computer -NewName $comp_name
        "Computer name has been set!" | Add-Content -Path $path_rename
        Log "Computer name set to $comp_name."
    }
}

$enterprise = Read-Host "Enable enterprise setup features? (y/n)"
if ($enterprise -like "*y*") {
    #Add the computer to a domain.
    if ($domain_current.Name -eq ""){
        Write-Host
        $domain_join = Read-Host "Would you like to join a domain? (y/n)"
        if ($domain_join.ToLower() -like "*y*"){
            $domain_new = Read-Host "What is the domain name?"
            try {
                Add-Computer -DomainName $domain_new
                Log "Successfully joined $domain_new."
                Log "Your computer will now reboot."
                Log "Please rerun script after reboot to continue setup."
                Start-Sleep -Seconds 1
                Log "Rebooting computer..."
                Start-Sleep -Seconds 5
                Restart-Computer
            } catch {
                Log "Failed to join $domain_new."
                Log $_
                exit
            }
        } else {Log "Declined to join domain."}
    }

    #Install network printers.
    Write-Host
    $print_ask = Read-Host "Would you like to add a network printer? (y/n)"
    $print_ask = $print_ask.ToLower()
    if ($print_ask -like "*y*") {
        $print_server = Read-Host "where is your print server?"
        try{
            Invoke-Item -Path $print_server
        } Catch {
            Log "Failed to add printers!"
        }
    } else {Log "No printers added."}
}

#Installs applications, based on user input. 
do {
    Write-Host
    $install = Read-Host "Would you like to install any software? (y/n)"
    $install = $install.ToLower()
    if ($install -eq "*y*") {
        do {
            Clear-Host
            foreach ($_ in $arr_install) {
                Write-Host "-$_`n"
            }
            $app = Read-Host "What would you like to install? Write 'done' to finish."
            switch ($app.ToLower()) {
                reader {Install "$url_adobe" "Adobe Reader"}
                firefox {Install "$url_firefox" "Firefox"}
                github {Install "$url_github" "GitHub Desktop"}
                notepad {Install "$url_notepad" "Notepad++"}
                spotify {Install "$url_spotify" "Spotify"}
                vscode {Install "$url_vscode" "Visual Studio Code"}
                vlc {Install "$url_vlc" "VLC Media Player"}
                Default {Write-Host "Please choose from the applications listed, or type done."}
            }
        } until ($app -eq 'done')
    } elseif ($install -eq 'no') {
        Log "No programs were installed."
    } else {
        Log "Please make a valid selection."
    }
} until ($install -eq "yes" -or $install -eq "no")




###################
##### CLEANUP #####
###################

#Remove some preinstalled apps
Write-Host
Log "Cleaning up preinstalled junk..."
Start-Sleep -Seconds 2

#Microsoft AppX bloat removal.
foreach ($_ in $arr_ms_bloat) {
    try {
        Get-AppxPackage *$_* -AllUsers | Remove-AppxPackage
        Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ $packages | Remove-AppxProvisionedPackage -Online
        Log "$_ has been removed."
    } catch {
        Log "Failed to remove $_."
    }
}

#Antivirus removal.
if (exist "%PROGRAMFILES(X86)%\Norton Security") {
    Invoke-WebRequest https://norton.com/nrnr -OutFile $path_temp/Norton_Remover.exe
    Start-Process "$path_temp/Norton_Remover.exe" /norestart /noreboot > NUL 2>&1
    pause
} elsif (exist "%PROGRAMFILES(X86)%\Norton Internet Security") {
    Invoke-WebRequest https://norton.com/nrnr -OutFile $path_temp/Norton_Remover.exe
    Start-Process "./tools/Norton_Remover.exe" /norestart /noreboot > NUL 2>&1
    pause
} elsif (exist "%PROGRAMFILES(X86)%\McAfee") {
    Invoke-WebRequest https://download.mcafee.com/molbin/iss-loc/SupportTools/MCPR/MCPR.exe -OutFile $path_temp/McAfee_Remover.exe
    Start-Process "$path_temp/McAfee_Remover.exe" /norestart /noreboot > NUL 2>&1
    pause
} elsif (exist "%PROGRAMFILES%\Spybot - Search & Destroy 2") {
    Start-Process "%PROGRAMFILES%\Spybot - Search & Destroy 2\unins000.exe" > NUL 2>&1
}

#Optimize all attached disks.
Write-Host
Log "Beginning disk optimization..."
ForEach ($_ in $disks) {
    Log "Beginning defrag on $_."
    defrag $_ /O | Out-Null
    Log "Completed defrag on $_."
}
Log "Disk optimization complete!"

Log "Tidying up..."
Remove-Item -path "$env:SystemDrive\temp" #Delete temp folder.
cleanmgr.exe | Out-Null #Run Disk Cleanup, wait until closed to continue.
Clear-RecycleBin #Empty the Recycle Bin.




###############
##### FIN #####
###############

Write-Host
Log "Setup completed!"
$reboot = Read-Host "Would you like to reboot this computer? (y/n)"
$reboot = $reboot.ToLower()
if ($reboot -like "*y*"){
    Log "Restarting computer."
    Start-Sleep -Seconds 5
    Restart-Computer
} else {
    Start-Sleep -Seconds 5
    exit
}