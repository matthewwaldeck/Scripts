<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-28-2019
    Language:   PowerShell
    Purpose:    Will perform routine maintenance tasks for Workstations.
    Last Edit:  07-02-2019
    Version:    v1.0.0

    Tasks:
      -Clean up temp files
      -Run Check Disk and report errors
      -Run SFC Scan and report errors
      -Log all results
      -Shutdown computer

    Note: Original code from the following link, has been modified to fit my needs.
    https://github.com/Mike-Rotec/PowerShell-Scripts/blob/master/Maintenance/WorkstationMaintenance.ps1
#>

#Variables
$LastBootUp = Get-CimInstance -Class Win32_OperatingSystem | Select-Object LastBootUpTime
$LastBootUp = (Get-Date) - $LastBootUp.LastBootUpTime | Select-Object Days -ExpandProperty Days
$OldDisk = Get-WmiObject -Class win32_logicaldisk | Select-Object Size,FreeSpace
$OldDisk = ($OldDisk.Size - $OldDisk.FreeSpace)

#Functions
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
      "$(Get-TimeStamp) - Check disk on $Disk started." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
      $Output = chkdsk $Disk | Select-String 'Windows has scanned the file system and found no problems.'
      if ($Output.ToString() -eq 'Windows has scanned the file system and found no problems.') {
          "$(Get-TimeStamp) - Check Disk completed on $Disk drive successfully." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
          $Script:CheckDisk = 0
      }
      else {
          "$(Get-TimeStamp) - Check Disk has been scheduled to run on reboot on $Disk." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
          Write-Output 'y' | chkdsk $Disk /f
          $Script:CheckDisk = 1
      }
  }
}

function OptimizeDrives {
  "$(Get-TimeStamp) - Beginning defrag on disks..." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  $Disks=Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
  ForEach ($Disk in $Disks) {
      "$(Get-TimeStamp) - Beginning defrag on $Disk." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
      defrag $Disk /O | Out-Null
      "$(Get-TimeStamp) - Completed defrag on $Disk." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  }
}

function RunSFCScan {
  # Run sfcscan /scannow
  "$(Get-TimeStamp) - Started SFC scan." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  sfc /ScanNow | Out-Null
  if ($LASTEXITCODE -eq 1) {
      "$(Get-TimeStamp) - Failed to run SFC scan." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  }
  else {"$(Get-TimeStamp) - Completed SFC scan." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log}
}

function CleanupTemp {
  # Needs to check for the existence of a temp directory!
  # Cleans up C:\Temp files if the last write time is older than 1 year.
  $TempDir = "$env:SystemDrive\Temp\"
  if (Test-Path $TempDir) {
    "$(Get-TimeStamp) - Cleaning up temp files in $TempDir..." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
    $GetTempDir = Get-ChildItem $TempDir -Recurse | Where-Object {$PSItem.LastWriteTime -lt (Get-Date).AddYears(-1)}
    foreach ($Item in $GetTempDir) {
        try {
            "$(Get-TimeStamp) - Removing $Item.Name from $TempDir." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
            Remove-Item $Item.FullName -Force -ErrorAction Stop
        }
        catch {
            "$(Get-TimeStamp) - Failed to remove $Item" | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
        }
    }
    try {
        $GetTempDir = Get-ChildItem $TempDir -Recurse | Where-Object {$PSItem.LastWriteTime -lt (Get-Date).AddYears(-1)}; $GetTempDir = $GetTempDir.Count
    }
    catch {
        "$(Get-TimeStamp) - No files in $TempDir meet criteria." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
    }
    if ($GetTempDir -gt 0) {
        "$(Get-TimeStamp) - There are $GetTempDir files remaining in $TempDir." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
    }
  } else {
    "$(Get-TimeStamp) - There is no temp file present!" | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  }
  Clear-Variable TempDir
}

function CleanupWinTemp {
  # Clean up the windows Temp folder
  $TempDir = $env:windir + '\Temp\'
  try {
      "$(Get-TimeStamp) - Cleaning up temp files in $TempDir..." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
      Remove-Item $TempDir\* -Recurse -Force -ErrorAction Stop
  }
  catch {
      "$(Get-TimeStamp) - Failed to clean all temp files in $TempDir." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
      $Remaining = Get-ChildItem $TempDir\* -Recurse; $Remaining = $Remaining.Count
      "$(Get-TimeStamp) - There are $Remaining items present in $TempDir after cleaning." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  }
  Clear-Variable TempDir
}

function CleanupAppDataTemp {
  # Cleans up local AppData Temp folder
  $TempDir = Get-ChildItem C:\Users -Exclude 'Public*', 'default*', '*ldap*', '*admin*', '*test*' | Select-Object FullName -ExpandProperty FullName
  foreach ($Dir in $TempDir) {
      try {
          $Dir = "$Dir\AppData\Local\Temp\"
          Get-ChildItem $Dir -Recurse | Select-Object FullName, LastWriteTime | Where-Object {$PSItem.LastWriteTime -lt (Get-Date).AddDays(-7)} | Select-Object FullName -ExpandProperty FullName | Remove-Item -Exclude *ssh* -Recurse -ErrorAction SilentlyContinue
          "$(Get-TimeStamp) - Cleaning up temp files in $Dir..." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
      }
      catch {
          "$(Get-TimeStamp) - Failed to clean all temp files in $Dir." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
          $Remaining = Get-ChildItem $Dir\* -Recurse; $Remaining = $Remaining.Count
          "$(Get-TimeStamp) - There are $Remaining items present in $Dir after cleaning." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
      }
  }
  Clear-Variable TempDir
}

function EmptyRecycleBin {
  # Empties the recycle bin
  try {
    $NewShell = New-Object -ComObject Shell.Application -ErrorAction Stop
    $GetRecycleBin = $NewShell.NameSpace(0xA)
    $GetRecycleBin.Items() | ForEach-Object {Remove-Item $PSItem.Path -Recurse -Force -ErrorAction Stop} -ErrorAction Stop
    "$(Get-TimeStamp) - Emptied recycle bin." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  }
  catch {
    "$(Get-TimeStamp) - ERROR: $($PSItem.Exception)" | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
    "$(Get-TimeStamp) - Failed to empty recycle bin." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  }
}

function CheckForErrors {
  # Used for error checking once maintenance has completed.
  if ($LastBootUp -gt 8) {
      Send-MailMessage `
          -SmtpServer domain `
          -To email `
          -From email `
          -Subject "Maintenance Alert on $env:COMPUTERNAME" `
          -Body "Maintenance Alert - $env:COMPUTERNAME has not been shutdown in $LastBootUp days.
Full logs can be found at $Log"
  }   
  if ($CheckDisk -eq 1) {
      Send-MailMessage `
          -SmtpServer domain `
          -To email `
          -From email `
          -Subject "Maintenance Alert on $env:COMPUTERNAME" `
          -Body "Maintenance Alert - Check disk error detected on $env:COMPUTERNAME.
Full logs can be found at $Log."   
  }
}

function ShutdownComputer {
  #Should be the last thing to run
  $Time = (Get-Date).ToString('yyyy-MM-dd hh:mm:ss tt')
  $ShutdownTime = (Get-Date).AddMinutes(30).ToString('yyyy-MM-dd hh:mm:ss tt')
  "$(Get-TimeStamp) - The last shutdown was $LastBootUp day(s) ago." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  "$(Get-TimeStamp) - Maintenance finished at $Time. Shutting down $env:COMPUTERNAME at $ShutdownTime." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  shutdown /s /t 1800
}


#Script
"$(Get-TimeStamp) - Maintenance started by $env:UserName" | Set-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log

if (!(Test-Administrator)) {
  "$(Get-TimeStamp) - Script must be run as administrator. Exiting script." | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  "$(Get-TimeStamp) - Maintenance completed!" | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
  exit
}

CleanupTemp
CleanupWinTemp
CleanupAppDataTemp
EmptyRecycleBin
OptimizeDrives
RunCheckDisk
RunSFCScan
#CheckForErrors

$NewDisk = Get-WmiObject -Class win32_logicaldisk | Select-Object Size
$NewDisk = ($OldDisk - $NewDisk) / 1GB,2

"You have freed up $NewDisk on your C: drive."
"$(Get-TimeStamp) - Maintenance completed!" | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
#ShutdownComputer