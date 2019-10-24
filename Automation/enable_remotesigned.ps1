<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       10-24-2019
    Language:   PowerShell
    Purpose:    Sets the execution policy such that the scripts I've written can be run on our computers.
    Last Edit:  10-24-2019
    Version:    v1.0.0
#>

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "set-executionpolicy remotesigned"
     Exit
    }
}