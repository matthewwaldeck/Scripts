<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-09-2018
    Language:   PowerShell
    Purpose:    Generates a CSV containing all users in the current domain.
    Last Edit:  07-09-2019
    Version:    v1.1.2
#>

# Allow AD commands
Import-Module ActiveDirectory

Write-Output "Generating C:\adusers.csv..."
Get-ADUser -Filter * | Select-Object -Property Name, ObjectClass, Enabled, UserPrincipalName, DistinguishedName | Export-Csv C:\adusers.csv
Write-Output "Done!"
Write-Output ""