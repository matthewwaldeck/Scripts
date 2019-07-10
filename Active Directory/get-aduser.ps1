<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-09-2018
    Language:   PowerShell
    Purpose:    Lists all users in the current domain.
    Last Edit:  07-09-2019
    Version:    v1.0.0
#>

# Allow AD commands
Import-Module ActiveDirectory

Get-ADUser -Filter * | Select-Object -Property Name, ObjectClass, Enabled, UserPrincipalName, DistinguishedName | Export-Csv C:\adusers_report.csv