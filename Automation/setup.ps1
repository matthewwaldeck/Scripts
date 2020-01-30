<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-26-2019
    Language:   PowerShell
    Purpose:    Automates the basic setup process for a new Windows PC.
    Last Edit:  01-30-2020
    Version:    2.0.2

    CHANGELOG:
    -Huge code cleanup
    -Improved logging
    -See TODO for future plans

    TASKS:
    -Create log file
    -Rename computer
    -Optimize all attached drives (if requested)
    -Reboot computer (if requested)

    TODO:
    -Ask to add printers
        -If yes, open CP dialogue and wait for window close.
    -Clean out Start Menu tiles
    -Uninstall useless default apps
#>

$logPath = "C:\Users\$env:UserName\Desktop\setup_$(get-date -f yyyy-MM-dd-HHmm).log" #Log file destination

# FUNCTIONS #
function Get-TimeStamp {
    return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
}

function rename {
    '' | Add-Content -Path $logPath
    $comp_name =  Read-Host "Enter desired computer name..."
    Rename-Computer -NewName $comp_name
    Write-Host "Computer name set to $comp_name."
    "$(Get-TimeStamp) - Computer name set to $comp_name." | Add-Content -Path $logPath
}

function optimize {
    '' | Add-Content -Path $logPath
    Write-Host "Optimizing and Defragging drives..."
    "$(Get-TimeStamp) - Beginning disk optimization..." | Add-Content -Path $logPath
    $Disks=Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
    ForEach ($Disk in $Disks) {
        "$(Get-TimeStamp) - Beginning defrag on $Disk." | Add-Content -Path $logPath
        defrag $Disk /O | Out-Null
        "$(Get-TimeStamp) - Completed defrag on $Disk." | Add-Content -Path $logPath
    }
    Write-Host "Disk optimization complete!..."
    "$(Get-TimeStamp) - Disk optimization complete!" | Add-Content -Path $logPath
}

function fin {
    '' | Add-Content -Path $logPath
    "$(Get-TimeStamp) - Setup completed!" | Add-Content -Path $logPath
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
"$(Get-TimeStamp) - Setup started by $env:UserName" | Set-Content -Path $logPath
'' | Add-Content -Path $logPath

#Set reboot flag.
$reboot = Read-Host "Would you like to reboot your PC upon completion? (y/n)"
"Reboot = $reboot" | Add-Content -Path $logPath

rename #Rename the PC, depenting on user input.
optimize #Optimize all drives, if requested.
fin #Reboot the computer or close session, if requested.