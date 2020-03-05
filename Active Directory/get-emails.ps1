<# DESCRIPTION
    Author:     Matt Waldeck
    Created:    03-05-2020
    Purpose:    Generate a CSV file of every user's location and email address. Filters out disabled accounts and system accounts.
    Last Edit:  03-05-2020
    Version:    v01.1.0
#>

Write-Host "Saving file to desktop..."
Get-ADUser -Filter {PasswordNeverExpires -eq $false -and Enabled -eq $true} -Properties office, emailaddress |`
Select-Object Name, office, emailaddress |`
Sort-Object Name | Export-Csv -Path "$env:USERPROFILE\Desktop\Emails and Locations.csv" -NoTypeInformation