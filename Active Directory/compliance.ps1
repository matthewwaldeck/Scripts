<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-04-2019
    Language:   PowerShell
    Purpose:    Checks all AD users against compliance policy.
    Last Edit:  07-04-2019
    Version:    v0.1.0

    Checks:
        - Do passwords expire?
        - Time since last login? (look for ghost accounts)
        - login name convention proper?
#>


# Enables AD commands
Import-Module ActiveDirectory


# Check for non-expiring passwords on enabled accounts.
function passwords {
    Get-ADUser -Filter {PasswordNeverExpires -eq $true -and enabled -eq $true} -Properties PasswordNeverExpires, PasswordLastSet |`
        Select-Object Name, PasswordLastSet, PasswordNeverExpires |`
        Sort-Object Name | Add-Content -Path "$env:USERPROFILE\Documents\compliance_passwords.csv" -NoTypeInformation -Force
}

# Check for old user accounts.
function audit_ghosts {
    # Set the date variable to three months in the past.
    $Date = (Get-Date).AddYears(-1)
    # Builds the CSV for old users.
    Get-ADUser -Filter {LastLogonTimeStamp -lt $Date -and enabled -eq $true} -Properties LastLogonTimeStamp |`
        Select-Object Name, @{Name = "Time Stamp"; Expression = {[DateTime]::FromFileTime($_.LastLogonTimeStamp).ToString('yyyy-MM-dd_hh:mm:ss')}} |`
        Sort-Object "Time Stamp" | Export-Csv "$env:USERPROFILE\Documents\compliance_ghosts.csv" -NoTypeInformation -Force
}