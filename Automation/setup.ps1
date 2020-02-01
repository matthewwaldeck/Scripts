<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-26-2019
    Language:   PowerShell
    Purpose:    Automates the basic setup process for a new Windows PC.
    Last Edit:  01-31-2020
    Version:    2.1.0

    TASKS:
    -Create log file
    -Rename computer
    -Ask to join Domain
    -Add printers
    -Optimize all attached drives
    -Reboot computer (if requested)
#>

# FUNCTIONS #
function Get-TimeStamp {
    return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
}

function rename {
    $comp_name =  Read-Host "Enter desired computer name, or press enter to continue."
    if ($comp_name -ne ""){
        Rename-Computer -NewName $comp_name
        Write-Host "Computer name set to $comp_name."
        "$(Get-TimeStamp) - Computer name set to $comp_name." | Add-Content -Path $logPath
    }
}

function domain {
    $domain = Get-ADDomain -Current LocalComputer
    if ($domain.Name -eq ""){
        $join = Read-Host "Would you like to join a domain?"
        if ($join -eq "yes"){
            $domain_name = Read-Host "What is the domain name?"
            try {
                Add-Computer -DomainName $domain_name
                "$(Get-TimeStamp) - Successfully joined $domain_name." | Add-Content -Path $logPath
                "Please rerun script to continue setup." | Add-Content -Path $logPath
                Restart-Computer
            }
            catch {
                Write-Host "Failed to join $domain_name"
                "$(Get-TimeStamp) - Failed to join $domain_name." | Add-Content -Path $logPath
                exit
            }
        }
    }
}

function printers {
    do {
        $printer = Read-Host "Enter the full path to the desired printer, or press enter to continue."
        if ($printer -ccontains "\\"){
            try {
                Add-Printer -ConnectionName $printer
                Write-Host "$printer has been installed!"
                "$(Get-TimeStamp) - $printer has been installed." | Add-Content -Path $logPath
            }
            catch {
                Write-Host "Failed to install printer!"
                "$(Get-TimeStamp) - $printer failed to install." | Add-Content -Path $logPath
            }
        } else {
            $confirm_print = Read-Host "Are you finished adding printers?"
            $confirm_print = $confirm_print.ToLower()
            if ($confirm_print -eq "yes"){
                $print = 1
            }
        }
    } while ($print -eq 0)
    "$(Get-TimeStamp) - Finished adding printers." | Add-Content -Path $logPath
}

function cleanup {
    #Clean up ads
    Get-AppxPackage *officehub* | Remove-AppxPackage
    Get-AppxPackage *skypeapp* | Remove-AppxPackage
    Get-AppxPackage *getstarted* | Remove-AppxPackage
    Get-AppxPackage *solitairecollection* | Remove-AppxPackage

    #There will be more apps, such as Netflix and some games, that may or may not be present on your system.
    #I have no included these becuase they are not constant, and change every so often.

    #Run Disk Cleanup, wait until closed to continue
    cleanmgr.exe | Out-Null
}

function optimize {
    Write-Host "Optimizing and Defragging drives..."
    "$(Get-TimeStamp) - Beginning disk optimization..." | Add-Content -Path $logPath
    $Disks=Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
    ForEach ($Disk in $Disks) {
        "$(Get-TimeStamp) - Beginning defrag on $Disk." | Add-Content -Path $logPath
        defrag $Disk /O | Out-Null
        "$(Get-TimeStamp) - Completed defrag on $Disk." | Add-Content -Path $logPath
    }
    Write-Host "Disk optimization complete!"
    "$(Get-TimeStamp) - Disk optimization complete!" | Add-Content -Path $logPath
}

function fin {
    "$(Get-TimeStamp) - Setup completed!" | Add-Content -Path $logPath
    $reboot = Read-Host "Would you like to reboot this computer?"
    $reboot = $reboot.ToLower()
    if ($reboot -eq "yes"){
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
$logPath = "C:\Users\$env:UserName\Desktop\setup_$(get-date -f yyyy-MM-dd-HHmm).log" #Log file destination
"$(Get-TimeStamp) - Setup started by $env:UserName" | Set-Content -Path $logPath

#Functions
rename
domain
printers
cleanup
optimize
fin