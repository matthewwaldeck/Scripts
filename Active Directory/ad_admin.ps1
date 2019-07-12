<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-28-2019
    Language:   PowerShell
    Purpose:    Launches AD with your domain administrator account, rather than your normal account.
    Last Edit:  07-04-2019
    Version:    v1.3.3
#>

# Seperate first and last name.
$login = $env:USERNAME 
$pos = $login.IndexOf(".")
$firstName = $login.Substring(0, $pos)
$lastName = $login.Substring($pos+1)

# Format to admin login. Change this part to whatever format used in your environment. This is an example.
$adLogin = $firstName + $lastName.Substring(0,1) + '.admin'

# Launches a CMD window and opens AD with the supplied credentials.
# Change DOMAIN below to your domain name.
Start-Process “C:\Windows\System32\cmd.exe” -workingdirectory $PSHOME -Credential "DOMAIN\$adLogin" -ArgumentList “/c dsa.msc”

# For testing, comment above line and uncomment block below.
<#
Write-Output $firstName
Write-Output $lastName
Write-Output $adLogin
#>