<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-28-2019
    Language:   PowerShell
    Purpose:    Perform routine maintenance tasks for Workstations.
    Last Edit:  06-28-2019
    Version:    v0.1.0

    Tasks:
      -Clean up temp files
      -Run Check Disk and report errors
      -Run SFC Scan and report errors
      -Defrag/optimize drives
      -Empty recycle bin
      -Log all results to desktop
      -Shutdown computer

    Reference: https://github.com/Mike-Rotec/PowerShell-Scripts/blob/master/Maintenance/WorkstationMaintenance.ps1
#>

#Variables


#Functions
function Get-TimeStamp {
  return "[{0:MM/dd/yy} at {0:HH:mm:ss}]" -f (Get-Date)
}

#Script
"Maintenance started on $(Get-TimeStamp)" | Set-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log
"Maintenance completed on $(Get-TimeStamp)" | Add-Content -Path C:\Users\$env:UserName\Desktop\maintenance.log