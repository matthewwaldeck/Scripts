<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       10-24-2019
    Purpose:    Sets the execution policy such that scripts can be run.
    Last Edit:  09-11-2020
    Version:    v1.0.1
#>

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "set-executionpolicy remotesigned"
     Exit
    }
}