<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-09-2019
    Language:   PowerShell
    Purpose:    Generates a CSV containing all computers in the current domain.
    Last Edit:  03-06-2020
    Version:    v1.1.0
#>

# Allow AD commands
Import-Module ActiveDirectory

# Console feedback
Write-Output "Generating $env:USERPROFILE\Desktop\Domain Computers.csv..."

# Select all computers in the domain and pick out the specified information
Get-ADComputer -Filter * -Properties Name, Enabled, OperatingSystem, CanonicalName |`
Select-Object -Property Name, Enabled, OperatingSystem, CanonicalName | Sort-Object Name |`
Export-Csv "$env:USERPROFILE\Desktop\Domain Computers.csv" -NoTypeInformation #CSV saves to desktop.

# Console feedback
Write-Output "Done!"
Write-Output ""