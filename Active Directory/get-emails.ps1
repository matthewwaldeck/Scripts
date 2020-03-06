<# DESCRIPTION
    Author:     Matt Waldeck
    Created:    03-05-2020
    Purpose:    Generate a CSV file of every user's location and email address. Filters out disabled and system accounts.
    Last Edit:  03-06-2020
    Version:    v1.2.0
#>

# Allow AD commands
Import-Module ActiveDirectory

# Console Feedback
Write-Host "Saving file to desktop..."

# Find the information and save it to the desktop
Get-ADUser -Filter {PasswordNeverExpires -eq $false -and Enabled -eq $true} -Properties office, emailaddress |`
Select-Object Name, office, emailaddress |`
Sort-Object Name | Export-Csv -Path "$env:USERPROFILE\Desktop\Emails and Locations.csv" -NoTypeInformation

# Console feedback
Write-Output "Done!"
Write-Output ""