<#
    DESCRIPTION
    Developer:  Mike Rotec/Matt Waldeck
    Date:       06-18-2018
    Language:   PowerShell
    Purpose:    Will perform routine maintenance tasks for servers.
    Last Edit:  07-29-2019
    Version:    v1.2.0

    Tasks:
        -Check capacity of all storage devices.
        -Run Check Disk and report errors
        -Run SFC Scan and report errors
        -Log all results

    Note: Original code from the following link, has been modified to fit my needs.
    https://github.com/Mike-Rotec/PowerShell-Scripts/blob/master/Maintenance/ServerMaintenance.ps1

    Do not run this file directly, use maintenance_server.bat to run with admin priviledges.
    This will ensure all features work properly.
#>

$logPath = "C:\Users\$env:UserName\Documents\Maintenance Reports\maintenance_$(get-date -f yyyy-MM-dd-HHmm).log" #Log file destination

function dirty_work {
  #Ensures creation of maintenance folder
  New-Item -Path "C:\Users\$env:UserName\Documents\Maintenance Reports\" -ItemType Directory | Out-Null

  #Create log file
  "$(Get-TimeStamp) - Archive started by $env:USERNAME" | Set-Content -Path $logPath
  "Log file will be written to C:\Users\$env:UserName\Documents\Maintenance Reports"
}

function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-TimeStamp {
    return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
}

function RunCheckDisk {
    # Get all disks and run chkdsk on them and log the output
    $Disks = Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
    foreach ($Disk in $Disks) {
        "$(Get-TimeStamp) - Check disk on $Disk started." | Add-Content -Path $logPath
        $Output = chkdsk $Disk | Select-String 'Windows has scanned the file system and found no problems.'
        if ($Output.ToString() -eq 'Windows has scanned the file system and found no problems.') {
            "$(Get-TimeStamp) - Check Disk completed on $Disk drive successfully." | Add-Content -Path $logPath
        }
        else {
            "$(Get-TimeStamp) - Check Disk has been scheduled to run on reboot on $Disk." | Add-Content -Path $logPath
            Write-Output 'y' | chkdsk $Disk /f
        }
    }
}

function RunSFCScan {
    # Run sfcscan /scannow
    "$(Get-TimeStamp) - Started SFC scan." | Add-Content -Path $logPath
    sfc /ScanNow | Out-Null
    if ($LASTEXITCODE -eq 1) {
        "$(Get-TimeStamp) - Failed to run SFC scan." | Add-Content -Path $logPath
    }
    else {
        "$(Get-TimeStamp) - Completed SFC scan." | Add-Content -Path $logPath}
}

function EmptyRecycleBin {
    # Empties the recycle bin
    try {
      $NewShell = New-Object -ComObject Shell.Application -ErrorAction Stop
      $GetRecycleBin = $NewShell.NameSpace(0xA)
      $GetRecycleBin.Items() | ForEach-Object {Remove-Item $PSItem.Path -Recurse -Force -ErrorAction Stop} -ErrorAction Stop
      "$(Get-TimeStamp) - Emptied recycle bin." | Add-Content -Path $logPath
    }
    catch {
      "$(Get-TimeStamp) - ERROR: $($PSItem.Exception)" | Add-Content -Path $logPath
      "$(Get-TimeStamp) - Failed to empty recycle bin." | Add-Content -Path $logPath
    }
}

function CheckDiskStatus {
    $storage = (Get-WmiObject -Class Win32_logicaldisk)
    foreach ($_ in $storage) {
        $free = $_.FreeSpace
        $left = ($free / $_.Size) * 100
        $left = [math]::Round($left)
        if ($left -gt "10") {
            "$(Get-TimeStamp) - " + $_.DeviceID + "\ has $left% remaining." |`
            Add-Content $logPath
        } else {
            Write-Output "!!!!!!!!!!!!!!!!!!!!" | Add-Content $logPath
            "$(Get-TimeStamp) - WARNING!" + $_.DeviceID + "\ has only $left% remaining free." |`
            Add-Content $logPath
            Write-Output "!!!!!!!!!!!!!!!!!!!!" | Add-Content $logPath
        }
    }
    
}


#Script
dirty_work

"$(Get-TimeStamp) - Server Maintenance started by $env:UserName" | Set-Content -Path $logPath
if (!(Test-Administrator)) {
  "$(Get-TimeStamp) - Script must be run as administrator. Exiting script." | Add-Content -Path $logPath
  "$(Get-TimeStamp) - Server Maintenance failed!" | Add-Content -Path $logPath
  exit
}

EmptyRecycleBin
RunCheckDisk
RunSFCScan
CheckDiskStatus

"$(Get-TimeStamp) - Server Maintenance completed!" | Add-Content -Path $logPath