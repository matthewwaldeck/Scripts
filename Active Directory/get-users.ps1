<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-09-2019
    Purpose:    Generates a CSV containing all active users in the current domain.
    Last Edit:  06-02-2021
    Version:    v1.3.0
#>

# Allow AD commands
Import-Module ActiveDirectory

# Console feedback
Write-Output "Generating $env:USERPROFILE\Desktop\Domain Users.csv..."

# Select all computers in the domain and pick out the specified information
Get-ADUser -Filter {PasswordNeverExpires -eq $false -and Enabled -eq $true} -Properties Name, Enabled, Office, Department, Description, LastLogonDate, LockedOut, EmailAddress, CanonicalName |`
Select-Object Name, Enabled, Office, Department, Description, LastLogonDate, LockedOut, EmailAddress, CanonicalName | Sort-Object Name |`
Export-Csv "$env:USERPROFILE\Downloads\Domain Users.csv" -NoTypeInformation #CSV saves to downloads folder.

# Console feedback
Write-Output "Done!"
Write-Output ""
Start-Sleep -Seconds 5