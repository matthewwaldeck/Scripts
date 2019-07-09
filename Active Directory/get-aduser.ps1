<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-09-2018
    Language:   PowerShell
    Purpose:    Lists all users in the current domain.
    Last Edit:  07-09-2019
    Version:    v0.1.0
#>

$users = Get-ADUser -Filter '*'

"get-aduser" | Set-Content -Path "C:\Users\$env:USERNAME\Desktop\AD_Users.log"

foreach ($_ in $users) {
    Select-Object $_.Name | Add-Content -Path "C:\Users\$env:USERNAME\Desktop\AD_Users.log"
}