<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       08-01-2018
    Language:   PowerShell
    Purpose:    Checks for driver updates for all installed devices.
    Last Edit:  08-01-2019
    Version:    v0.1.0
#>

Get-WmiObject Win32_PnPSignedDriver| Select-Object DeviceName, Manufacturer, DriverVersion