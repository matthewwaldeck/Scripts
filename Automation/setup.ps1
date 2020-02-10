<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       02-25-2020
    Language:   PowerShell
    Purpose:    Automates the basic setup process for a new Windows PC.
    Last Edit:  02-10-2020
    Version:    0.1.2

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
        "Downloading $program_name..." | Set-Content -Path $logPath
        (New-Object System.Net.WebClient).DownloadFile($url_download, $output)
        Write-Host "Download complete! Running install file..."
        "Download complete! Running install file..." | Set-Content -Path $logPath
        Start-Process $output "/S"
        Write-Host "$program_name has been installed successfully!"
        "$program_name has been installed!" | Set-Content -Path $logPath
    } catch [System.Net.WebException] {
        #Download failed.
        Write-Host "$program_name failed to download!"
        "$program_name failed to download!" | Set-Content -Path $logPath
        $_ | Set-Content -Path $logPath
    } catch {
        #Install failed.
        Write-Host '$program_name failed to install!'
        "$program_name failed to install!" | Set-Content -Path $logPath
        $_ | Set-Content -Path $logPath
    }
}

function Add_Printer {
    <# When run, requests the network path to a printer. The function will then attempt to connect to the printer.
    If it fails, it will save the error message to the log. In future, will also support IP lookup. #>
    $printer = Read-Host "Enter the full path to the desired printer."
    try {
        Add-Printer -ConnectionName $printer
        Write-Host "$printer has been installed!"
        "$(Get-TimeStamp) - $printer has been installed." | Add-Content -Path $logPath
    }
    catch {
        Write-Host "Failed to install printer!"
        "$(Get-TimeStamp) - $printer failed to install. Check the log for details." | Add-Content -Path $logPath
        $_ | Set-Content -Path $logPath
    }
}


# VARIABLES #
$logPath = "C:\Users\$env:UserName\Desktop\setup_$(get-date -f yyyy-MM-dd-HHmm).log"
$domain = Get-ADDomain -Current LocalComputer
$ask_printers = ""
$temp_path = Test-Path -Path "$env:SystemDrive\Users\temp"
$disks = Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
$array_basic = "Adobe Reader", "Chrome"
$array_all = "Adobe Reader", "Chrome", "Firefox", "VLC"
$url_chrome = "https://www.google.com/chrome/thank-you.html?statcb=1&installdataindex=empty&defaultbrowser=0#"
$url_firefox = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-CA&attribution_code=c291cmNlPXd3dy5nb29nbGUuY29tJm1lZGl1bT1yZWZlcnJhbCZjYW1wYWlnbj0obm90IHNldCkmY29udGVudD0obm90IHNldCkmZXhwZXJpbWVudD0obm90IHNldCkmdmFyaWF0aW9uPShub3Qgc2V0KQ..&attribution_sig=477b9b68ad048e9ad2f25dcfa51f2d4053ae39e1832bd11e63fbd6eb0f4341d6"
$url_reader = "https://get.adobe.com/reader/download/?installer=Reader_DC_2019.021.20058_English_for_Windows&os=Windows%2010&bowser_type=KHTML&browser_dist=Chrome&dualoffer=false&mdualoffer=true&cr=false&stype=7468&d=McAfee_Security_Scan_Plus&d=McAfee_Safe_Connect"
$url_vlc = #Need to find VLC download link.


# SCRIPT #
#Create logfile
"$(Get-TimeStamp) - Setup started by $env:UserName" | Set-Content -Path $logPath

#Rename the computer.
$comp_name =  Read-Host "Enter desired computer name, or press enter to continue."
if ($comp_name -ne ""){
    Rename-Computer -NewName $comp_name
    Write-Host "Computer name set to $comp_name."
    "$(Get-TimeStamp) - Computer name set to $comp_name." | Add-Content -Path $logPath
}

#Add the computer to a domain.
if ($domain.Name -eq ""){
    $join = Read-Host "Would you like to join a domain?"
    if ($join -eq "yes"){
        $domain_name = Read-Host "What is the domain name?"
        try {
            Add-Computer -DomainName $domain_name
            "$(Get-TimeStamp) - Successfully joined $domain_name. Rebooting computer..." | Add-Content -Path $logPath
            "Successfully joined $domain_name. Your computer will now reboot. Please rerun script to continue setup."
            Restart-Computer
        } catch {
            Write-Host "Failed to join $domain_name"
            "$(Get-TimeStamp) - Failed to join $domain_name." | Add-Content -Path $logPath
            $_ | Set-Content -Path $logPath
            exit
        }
    }
}

#Install network printers.
do {
    $ask_printers = Read-Host "Would you like to add a network printer?"
    $ask_printers = $ask_printers.ToLower()
    if ($ask_printers -eq "yes") {
        Add_Printer
    } else {
        Write-Host "Finished adding printers."
        "$(Get-TimeStamp) - Finished adding printers." | Add-Content -Path $logPath
    }
} until ($ask_printers -eq "no")

#Make sure temp folder exists on system drive.
if ($temp_path -eq $false) {
  New-Item -Path "$env:SystemDrive\Users\temp" -ItemType Directory | Out-Null
  Write-Host "Created temp directory."
  "Created temp directory!" | Set-Content -Path $logPath
} else {
  Write-Host "Temp directory already present!"
  "Temp directory already present!" | Set-Content -Path $logPath
}

#Install some basic programs.
do {
    #Write the available app packages to the terminal. Please expand these arrays as software is added.
    Clear-Host
    Write-Host "Basic Apps:"
    foreach ($app in $array_basic) {
        Write-Host "$app"
    }
    Write-Host ""
    Write-Host "All Apps:"
    foreach ($app in $array_all) {
        Write-Host "$app"
    }

    #Ask for a selection of apps to install, or enter "none" to skip to the next task.
    Write-Host ""
    $install = Read-Host "Would you like to install a BASIC set of programs, ALL available software, or NONE?"
    $install = $install.ToLower()
    if ($install -eq 'basic') {
        install_programs "$url_reader" "Adobe Reader"
        Install_Programs "$url_chrome" "Chrome"
    } elseif ($install -eq 'all') {
        install_programs "$url_reader" "Adobe Reader"
        Install_Programs "$url_chrome" "Chrome"
        install_programs "$url_firefox" "Firefox"
        install_programs "$url_vlc" "VLC"
    } elseif ($install -eq 'none') {
        Write-Host "Nothing has been installed."
        "No programs were installed." | Add-Content -Path $logPath
    } else {
        Write-Host "Please make a valid selection."
    }
} while ($install -ne 'basic' -or 'all' -or 'none')

#Delete installer files.
Remove-Item –path "$env:SystemDrive\temp\Adobe Reader.exe"
Remove-Item –path "$env:SystemDrive\temp\Chrome.exe"
Remove-Item –path "$env:SystemDrive\temp\Firefox.exe"
Remove-Item –path "$env:SystemDrive\temp\VLC.exe"

#Get rid of a few preinstalled ads
Get-AppxPackage *officehub* | Remove-AppxPackage
Get-AppxPackage *skypeapp* | Remove-AppxPackage
Get-AppxPackage *getstarted* | Remove-AppxPackage
Get-AppxPackage *solitairecollection* | Remove-AppxPackage

#Run Disk Cleanup, wait until closed to continue.
cleanmgr.exe | Out-Null

#Optimize all attached disks.
Write-Host "Optimizing and Defragging drives..."
"$(Get-TimeStamp) - Beginning disk optimization..." | Add-Content -Path $logPath
ForEach ($disk in $disks) {
    "$(Get-TimeStamp) - Beginning defrag on $disk." | Add-Content -Path $logPath
    defrag $disk /O | Out-Null
    "$(Get-TimeStamp) - Completed defrag on $disk." | Add-Content -Path $logPath
}
Write-Host "Disk optimization complete!"
"$(Get-TimeStamp) - Disk optimization complete!" | Add-Content -Path $logPath

#Finish up
Write-Host "Setup complete!"
"$(Get-TimeStamp) - Setup completed!" | Add-Content -Path $logPath
$reboot = Read-Host "Would you like to reboot this computer?"
$reboot = $reboot.ToLower()
if ($reboot -eq "yes"){
    Write-Host "Restarting your PC..."
    "$(Get-TimeStamp) - Restarting computer." | Add-Content -Path $logPath
    Start-Sleep -Seconds 5
    Restart-Computer
} else {
    Start-Sleep -Seconds 5
    exit
}