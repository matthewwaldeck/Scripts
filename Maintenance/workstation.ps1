<#
    DESCRIPTION
    Developer:  Mike Rotec/Matt Waldeck
    Date:       06-18-2018
    Purpose:    Will perform routine maintenance tasks for workstations.
    Last Edit:  09-11-2020
    Version:    v1.4.3

    Tasks:
      -Clean up temp files
      -Run Check Disk and report errors
      -Run SFC Scan and report errors
      -Log all results
      -Shutdown computer (If requested)

    Note: Original code from the following link, has been significantly modified and added to.
    https://github.com/Mike-Rotec/PowerShell-Scripts/blob/master/Maintenance/WorkstationMaintenance.ps1

    Do not run this file directly, use maintenance_workstation.bat to run with admin priviledges.
    (Or run from admin console session...) This will ensure all features work properly.
#>

#Get pre-maintenance used disk space
$TempDisk = Get-WmiObject -Class win32_logicaldisk
$OldDisk = ([Math]::Round($TempDisk.Capacity /1GB,2)) - ([Math]::Round($TempDisk.FreeSpace /1GB,2))
$logPath = "C:\Users\$env:UserName\Documents\Maintenance Reports\'$env:COMPUTERNAME'_$(get-date -f yyyy-MM-dd-HHmm).log" #Log file destination

function dirty_work {
  #Ensures creation of maintenance folder
  $path = Test-Path -Path "C:\Users\$env:UserName\Documents\Maintenance Reports\"
  if ($path -eq $false) {
    New-Item -Path "C:\Users\$env:UserName\Documents\Maintenance Reports\" -ItemType Directory | Out-Null
    "Created log directory!" | Set-Content -Path $logPath
  } else {
    Write-Host "Log directory already present!"
    "Log directory already present!" | Set-Content -Path $logPath 
  }

  #Create log file
  "$(Get-TimeStamp) - Maintenance started by $env:USERNAME" | Set-Content -Path $logPath
  "Log file will be written to C:\Users\$env:UserName\Documents\Maintenance Reports"
}

#Functions
function Test-Administrator {
  "Testing for admin priviledges..."
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-TimeStamp {
  return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
}

function RunCheckDisk {
  # Get all disks and run chkdsk on them and log the output
  "Running CheckDisk..."
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

function OptimizeDrives {
  "Optimizing and Defragging drives..."
  "$(Get-TimeStamp) - Beginning defrag on disks..." | Add-Content -Path $logPath
  $Disks=Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
  ForEach ($Disk in $Disks) {
      "$(Get-TimeStamp) - Beginning defrag on $Disk." | Add-Content -Path $logPath
      defrag $Disk /O | Out-Null
      "$(Get-TimeStamp) - Completed defrag on $Disk." | Add-Content -Path $logPath
  }
}

function RunSFCScan {
  # Run sfcscan /scannow
  "Running SFC scan..."
  "$(Get-TimeStamp) - Started SFC scan." | Add-Content -Path $logPath
  sfc /ScanNow | Out-Null
  if ($LASTEXITCODE -eq 1) {
      "$(Get-TimeStamp) - Failed to run SFC scan." | Add-Content -Path $logPath
  }
  else {
    "$(Get-TimeStamp) - Completed SFC scan." | Add-Content -Path $logPath}
}

function CleanupTemp {
  # Cleans up C:\Temp files if the last write time is older than 1 year.
  "Cleaning up temp folder (if present)..."
  $TempDir = "$env:SystemDrive\Temp\"
  if (Test-Path $TempDir) {
    "$(Get-TimeStamp) - Cleaning up temp files in $TempDir..." | Add-Content -Path $logPath
    $GetTempDir = Get-ChildItem $TempDir -Recurse | Where-Object {$PSItem.LastWriteTime -lt (Get-Date).AddYears(-1)}
    foreach ($Item in $GetTempDir) {
        try {
            "$(Get-TimeStamp) - Removing $Item.Name from $TempDir." | Add-Content -Path $logPath
            Remove-Item $Item.FullName -Force -ErrorAction Stop
        }
        catch {
            "$(Get-TimeStamp) - Failed to remove $Item" | Add-Content -Path $logPath
        }
    }
    try {
        $GetTempDir = Get-ChildItem $TempDir -Recurse | Where-Object {$PSItem.LastWriteTime -lt (Get-Date).AddYears(-1)}; $GetTempDir = $GetTempDir.Count
    }
    catch {
        "$(Get-TimeStamp) - No files in $TempDir meet criteria." | Add-Content -Path $logPath
    }
    if ($GetTempDir -gt 0) {
        "$(Get-TimeStamp) - There are $GetTempDir files remaining in $TempDir." | Add-Content -Path $logPath
    }
  } else {
    "$(Get-TimeStamp) - There is no temp file present!" | Add-Content -Path $logPath
  }
  Clear-Variable TempDir
}

function CleanupWinTemp {
  # Clean up the windows Temp folder
  "Cleaning up Windows temp folder..."
  $TempDir = $env:windir + '\Temp\'
  try {
      "$(Get-TimeStamp) - Cleaning up temp files in $TempDir..." | Add-Content -Path $logPath
      Remove-Item $TempDir\* -Recurse -Force -ErrorAction Stop
  }
  catch {
      "$(Get-TimeStamp) - Failed to clean all temp files in $TempDir." | Add-Content -Path $logPath
      $Remaining = Get-ChildItem $TempDir\* -Recurse; $Remaining = $Remaining.Count
      "$(Get-TimeStamp) - There are $Remaining items present in $TempDir after cleaning." | Add-Content -Path $logPath
  }
  Clear-Variable TempDir
}

function CleanupAppDataTemp {
  "Cleaning up AppData temp folder..."
  # Cleans up local AppData Temp folder
  $TempDir = Get-ChildItem C:\Users -Exclude 'Public*', 'default*', '*ldap*', '*admin*', '*test*' | Select-Object FullName -ExpandProperty FullName
  foreach ($Dir in $TempDir) {
      try {
          $Dir = "$Dir\AppData\Local\Temp\"
          Get-ChildItem $Dir -Recurse | Select-Object FullName, LastWriteTime | Where-Object {$PSItem.LastWriteTime -lt (Get-Date).AddDays(-7)} | Select-Object FullName -ExpandProperty FullName | Remove-Item -Exclude *ssh* -Recurse -ErrorAction SilentlyContinue
          "$(Get-TimeStamp) - Cleaning up temp files in $Dir..." | Add-Content -Path $logPath
      }
      catch {
          "$(Get-TimeStamp) - Failed to clean all temp files in $Dir." | Add-Content -Path $logPath
          $Remaining = Get-ChildItem $Dir\* -Recurse; $Remaining = $Remaining.Count
          "$(Get-TimeStamp) - There are $Remaining items present in $Dir after cleaning." | Add-Content -Path $logPath
      }
  }
  Clear-Variable TempDir
}

function EmptyRecycleBin {
  # Empties the recycle bin
  "Emptying the Recyle Bin..."
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

function ShutdownComputer {
  #Should be the last thing to run
  $Time = (Get-Date).ToString('yyyy-MM-dd hh:mm:ss tt')
  $ShutdownTime = (Get-Date).AddMinutes(30).ToString('yyyy-MM-dd hh:mm:ss tt')
  "$(Get-TimeStamp) - The last shutdown was $LastBootUp day(s) ago." | Add-Content -Path $logPath
  "$(Get-TimeStamp) - Maintenance finished at $Time. Shutting down $env:COMPUTERNAME at $ShutdownTime." | Add-Content -Path $logPath
  shutdown /s /t 1800
}


#Script
dirty_work

if (!(Test-Administrator)) {
  "$(Get-TimeStamp) - Script must be run as administrator. Exiting script." | Add-Content -Path $logPath
  "$(Get-TimeStamp) - Maintenance failed!" | Add-Content -Path $logPath
  exit
}

"Would you like to shut down your PC? (y/n)"
$shutdown = Read-Host

Clear-Host
CleanupTemp
CleanupWinTemp
CleanupAppDataTemp
EmptyRecycleBin
OptimizeDrives
RunCheckDisk
RunSFCScan

#Get post-maintenance used disk space
$TempDisk = Get-WmiObject -Class win32_logicaldisk
$NewDisk = ([Math]::Round($TempDisk.Capacity /1GB,2)) - ([Math]::Round($TempDisk.FreeSpace /1GB,2))

"You have freed up " + ($OldDisk-$NewDisk) + " GB on your C: drive." | Add-Content -Path $logPath
"$(Get-TimeStamp) - Maintenance completed!" | Add-Content -Path $logPath
"$(Get-TimeStamp) - Shutdown = $shutdown" | Add-Content -Path $logPath
if ($shutdown -eq 'y') {
  "$(Get-TimeStamp) - Shutting down workstation in 30 minutes." | Add-Content -Path $logPath
  ShutdownComputer
} else {
  "$(Get-TimeStamp) - Workstation will not shut down." | Add-Content -Path $logPath
}