<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-04-2019
    Language:   PowerShell
    Purpose:    Checks all AD users against compliance policy.
    Last Edit:  07-04-2019
    Version:    v0.1.0 (Beta)

    Checks:
        - Do passwords expire?
        - Time since last login? (look for ghost accounts)
#>


# Enables AD commands
Import-Module ActiveDirectory


# Check for non-expiring passwords on enabled accounts.
function passwords {
    Get-ADUser -Filter {PasswordNeverExpires -eq $true -and enabled -eq $true} -Properties PasswordNeverExpires, PasswordLastSet |`
        Select-Object Name, PasswordLastSet, PasswordNeverExpires |`
        Sort-Object Name | Export-Csv -Path "$env:USERPROFILE\Documents\compliance.csv" -NoTypeInformation -Force
}

# Add a blank line to the CSV file.
"" | Add-Content -Path "$env:USERPROFILE\Documents\compliance.csv"

# Check for old user accounts.
function audit_ghosts {
    # Set the date variable to three months in the past.
    $Date = (Get-Date).AddYears(-1)
    # Builds the CSV for old users.
    Get-ADUser -Filter {LastLogonTimeStamp -lt $Date -and enabled -eq $true} -Properties LastLogonTimeStamp |`
        Select-Object DisplayName, @{Name = "Time Stamp"; Expression = {[DateTime]::FromFileTime($_.LastLogonTimeStamp).ToString('yyyy-MM-dd_hh:mm:ss')}} |`
        Sort-Object "Time Stamp" | Add-Content -Path "$env:USERPROFILE\Documents\compliance.csv" -NoTypeInformation -Force
}


# Run the functions
passwords
audit_ghosts