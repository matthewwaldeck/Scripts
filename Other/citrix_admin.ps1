<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-11-2019
    Language:   PowerShell
    Purpose:    Launches Citrix AppCenter with your domain administrator account, rather than your normal account.
    Last Edit:  07-12-2019
    Version:    v1.1.0
#>

# Seperate first and last name.
$login = $env:USERNAME 
$pos = $login.IndexOf(".")
$firstName = $login.Substring(0, $pos)
$lastName = $login.Substring($pos+1)

# Format to admin login. Change this part to whatever format used in your environment. This is an example.
$adLogin = $firstName + $lastName.Substring(0,1) + '.admin'

# Moves to the file location, and opens the login dialogue.
# Done in two steps literally because PowerShell gets mad if I don't.
# Change DOMAIN below to your domain name.
Set-Location 'C:\Program Files (x86)\Citrix\Citrix Delivery Services Console\Framework'
Start-Process powershell.exe -Credential "DOMAIN\$adLogin" -NoNewWindow -ArgumentList "Start-Process .\CmiLaunch.exe -Verb runAs"

# For testing, comment above line and uncomment block below.
<#
Write-Output $firstName
Write-Output $lastName
Write-Output $adLogin
#>