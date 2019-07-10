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

# Console feedback
Write-Output "Generating C:\adusers.csv..."

# Select all computers in the domain and pick out the specified information
Get-ADUser -Filter * | Select-Object -Property Name, ObjectClass, Enabled, UserPrincipalName, DistinguishedName |`
Export-Csv C:\adusers.csv #Export to root of C:\

# Console feedback
Write-Output "Done!"
Write-Output ""