<#
    DESCRIPTION
    Author:     Matt Waldeck
    Created:    07-26-2019
    Purpose:    Automates the basic setup process for a new Windows PC.
    Last Edit:  02-28-2020
    Version:    0.2.0

    TASKS:
    -Create a log file
    -Rename the computer
    -Join a Domain
    -Add network printers
    -Install some basic programs
    -Clean up
    -Optimize all attached drives
    -Ask to reboot computer
#>


# FUNCTIONS #
function Get-TimeStamp {
    <# This function simply returns a timestamp of the current date and time.
    It's used in the logs so I can look and see if something is taking too long. #>
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
        "Download complete! Running install file..." | Set-Content -Path $path_log
        Start-Process $output "/S"
        Write-Host "$program_name has been installed successfully!"
        "$program_name has been installed!" | Set-Content -Path $path_log
    } catch [System.Net.WebException] {
        #Download failed.
        Write-Host "$program_name failed to download!"
        "$program_name failed to download!" | Set-Content -Path $path_log
        $_ | Set-Content -Path $path_log
    } catch {
        #Install failed.
        Write-Host '$program_name failed to install!'
        "$program_name failed to install!" | Set-Content -Path $path_log
        $_ | Set-Content -Path $path_log
    }
}


# VARIABLES #
$disks = Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
$domain_current = Get-ADDomain -Current LocalComputer
$domain_new = ""
$install = ""
$path_log = "C:\Users\$env:UserName\Desktop\setup_$(get-date -f yyyy-MM-dd-HHmm).log"
$path_temp = "$env:SystemDrive\temp"
$path_rename = "$env:SystemDrive\temp\rename.flag"
$print_ask = ""
$print_server = ""
$url_adobe = "https://get.adobe.com/reader/download/?installer=Reader_DC_2020.006.20034_English_for_Windows&os=Windows%2010&browser_type=KHTML&browser_dist=Chrome&dualoffer=false&mdualoffer=true&stype=7491&d=McAfee_Security_Scan_Plus&d=McAfee_Safe_Connect"
$url_chrome = "https://www.google.com/chrome/thank-you.html?statcb=1&installdataindex=empty&defaultbrowser=0#"
$url_citrix = "https://www.citrix.com/downloads/workspace-app/windows/workspace-app-for-windows-latest.html#ctx-dl-eula"


# SCRIPT #
#Create logfile
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
    $join = Read-Host "Would you like to join a domain?"
    if ($join -eq "yes"){
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

#Install some basic programs.
do {
    Write-Host ""
    $install = Read-Host "Would you like to install some basic software?"
    $install = $install.ToLower()
    if ($install -eq 'yes') {
        install_programs "$url_adobe" "Adobe Reader"
        Install_Programs "$url_chrome" "Chrome"
        Install_Programs "$url_citrix" "Citrix"
    } elseif ($install -eq 'no') {
        Write-Host "Nothing has been installed."
        "No programs were installed." | Add-Content -Path $path_log
    } else {
        Write-Host "Please make a valid selection."
    }
} until ($install -eq "yes" -or $install -eq "no")

#Clean up temp folder.
Remove-Item –path "$env:SystemDrive\temp\Adobe Reader.exe"
Remove-Item –path "$env:SystemDrive\temp\Chrome.exe"
Remove-Item -path $path_rename

#Get rid of a few preinstalled ads
Get-AppxPackage *officehub* | Remove-AppxPackage
Get-AppxPackage *skypeapp* | Remove-AppxPackage
Get-AppxPackage *getstarted* | Remove-AppxPackage
Get-AppxPackage *solitairecollection* | Remove-AppxPackage

#Run Disk Cleanup, wait until closed to continue.
cleanmgr.exe | Out-Null

#Optimize all attached disks.
Write-Host "Optimizing and Defragging drives..."
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