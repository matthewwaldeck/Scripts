<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-28-2019
    Language:   PowerShell
    Purpose:    Will perform routine maintenance tasks for Workstations.
    Last Edit:  06-28-2019
    Version:    v0.1.0

    Tasks:
      -Clean up temp files
      -Run Check Disk and report errors
      -Run SFC Scan and report errors
      -Log all results
      -Shutdown computer

    Note: https://github.com/Mike-Rotec/PowerShell-Scripts/blob/master/Maintenance/WorkstationMaintenance.ps1
#>

#Variables


#Functions
function Get-TimeStamp {
  return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
}

function RunCheckDisk {
  # Get all disks and run chkdsk on them and log the output
  $Disks = Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
  foreach ($Disk in $Disks) {
      "Check disk on $Disk started." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
      $Output = chkdsk $Disk | Select-String 'Windows has scanned the file system and found no problems.'
      if ($Output.ToString() -eq 'Windows has scanned the file system and found no problems.') {
          "Check Disk completed on $Disk drive successfully." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
          $Script:CheckDisk = 0
      }
      else {
          "Check Disk has been scheduled to run on reboot on $Disk." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
          Write-Output 'y' | chkdsk $Disk /f
          $Script:CheckDisk = 1
      }
  }
}

function OptimizeDrives {
  "Beginning defrag on disks..." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  $Disks=Get-WmiObject -Class win32_logicaldisk | Where-Object {$PSItem.DriveType -eq 3} | Select-Object Name -ExpandProperty Name
  ForEach ($Disk in $Disks) {
      "Beginning defrag on $Disk." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
      defrag $Disk /O | Out-Null
      "Completed defrag on $Disk." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  }
}

function RunSFCScan {
  # Run sfcscan /scannow
  "Started SFC scan." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  sfc /ScanNow | Out-Null
  if ($LASTEXITCODE -eq 1) {
      "Failed to run SFC scan." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  }
  else {"Completed SFC scan." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log}
}

function CleanupTemp {
  # Cleans up C:\Temp files if the last write time is older than 1 year.
  $TempDir = "$env:SystemDrive\Temp\"
  "Cleaning up temp files in $TempDir..." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  $GetTempDir = Get-ChildItem $TempDir -Recurse | Where-Object {$PSItem.LastWriteTime -lt (Get-Date).AddYears(-1)}
  foreach ($Item in $GetTempDir) {
      try {
          "Removing $Item.Name from $TempDir." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
          Remove-Item $Item.FullName -Force -ErrorAction Stop
      }
      catch {
          "Failed to remove $Item" | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
      }
  }
  try {
      $GetTempDir = Get-ChildItem $TempDir -Recurse | Where-Object {$PSItem.LastWriteTime -lt (Get-Date).AddYears(-1)}; $GetTempDir = $GetTempDir.Count
  }
  catch {
      "No files in $TempDir meet criteria." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  }
  if ($GetTempDir -gt 0) {
      "There are $GetTempDir files remaining in $TempDir." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  }
}

function CleanupWinTemp {
  # Clean up the windows Temp folder
  $TempDir = $env:windir + '\Temp\'
  try {
      "Cleaning up temp files in $TempDir..." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
      Remove-Item $TempDir\* -Recurse -Force -ErrorAction Stop
  }
  catch {
      "Failed to clean all temp files in $TempDir." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
      $Remaining = Get-ChildItem $TempDir\* -Recurse; $Remaining = $Remaining.Count
      "There are $Remaining items present in $TempDir after cleaning." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
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
          "Cleaning up temp files in $Dir..." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
      }
      catch {
          "Failed to clean all temp files in $Dir." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
          $Remaining = Get-ChildItem $Dir\* -Recurse; $Remaining = $Remaining.Count
          "There are $Remaining items present in $Dir after cleaning." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
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
    "$(Get-TimeStamp) Emptied recycle bin." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  }
  catch {
    "$(Get-TimeStamp) ERROR - $($PSItem.Exception)" | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
    "$(Get-TimeStamp) Failed to empty recycle bin." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
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
  ###!!!Commented most of this out as it will never be seen by the user as the task must be run as SYSTEM to work properly with Task Scheduler via GPO.!!!###
  # Should be the last thing to run
  #[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
  #$Prompt=[Microsoft.VisualBasic.Interaction]::MsgBox("Scheduled maintenance has started, would you like to cancel the shutdown?",'YesNo,Question', "IT")
  $Time = (Get-Date).ToString('yyyy-MM-dd hh:mm:ss tt')
  $ShutdownTime = (Get-Date).AddMinutes(30).ToString('yyyy-MM-dd hh:mm:ss tt')
  <#
if ($Prompt.ToString() -eq "Yes") {
 [Microsoft.VisualBasic.Interaction]::MsgBox("The shutdown has been cancelled.",'OKOnly,Information', "IT")
 Write-Log "User cancelled shutdown."
 Write-Log "The last shutdown was $LastBootUp days ago."
 Write-Log "Maintenance finished at $Time. No shutdown scheduled."
 exit 0
 } else {
 #>
  "The last shutdown was $LastBootUp day(s) ago." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  "Maintenance finished at $Time. Shutting down $env:COMPUTERNAME at $ShutdownTime." | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
  #[Microsoft.VisualBasic.Interaction]::MsgBox("A shutdown has been scheduled to occur in 30 minutes.",'OKOnly,Information', "IT")
  shutdown /s /t 1800
  #}
}


#Script
"Maintenance started on $(Get-TimeStamp) by $env:UserName" | Set-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
CleanupTemp
CleanupWinTemp
CleanupAppDataTemp
EmptyRecycleBin
CheckForErrors
"Maintenance completed on $(Get-TimeStamp)" | Add-Content -Path C:\Users\Matt.waldeck\Desktop\maintenance.log
ShutdownComputer

Pause