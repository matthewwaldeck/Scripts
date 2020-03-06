<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-09-2019
    Language:   PowerShell
    Purpose:    Generates a CSV containing all users in the current domain.
    Last Edit:  03-06-2020
    Version:    v1.2.1
#>

# Allow AD commands
Import-Module ActiveDirectory

# Console feedback
Write-Output "Generating $env:USERPROFILE\Desktop\Domain Users.csv..."

# Select all computers in the domain and pick out the specified information
Get-ADUser -Filter * -Properties Name, Enabled, Office, Department, Description, LastLogonDate, LockedOut, EmailAddress, CanonicalName |`
Select-Object Name, Enabled, Office, Department, Description, LastLogonDate, LockedOut, EmailAddress, CanonicalName | Sort-Object Name |`
Export-Csv "$env:USERPROFILE\Desktop\Domain Users.csv" -NoTypeInformation #CSV saves to desktop.

# Console feedback
Write-Output "Done!"
Write-Output ""