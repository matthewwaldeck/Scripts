<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-09-2018
    Language:   PowerShell
    Purpose:    Generates a CSV containing all computers in the current domain.
    Last Edit:  07-09-2019
    Version:    v1.0.0
#>

# Allow AD commands
Import-Module ActiveDirectory

Write-Output "Generating C:\adcomputers.csv..."
Get-ADComputer -Filter * | Select-Object -Property Name, ObjectClass, Enabled, DistinguishedName | Export-Csv C:\adcomputers.csv
Write-Output "Done!"
Write-Output ""