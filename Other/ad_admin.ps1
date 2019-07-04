<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-28-2019
    Language:   PowerShell
    Purpose:    Lists all installed software and their information.
    Last Edit:  07-04-2019
    Version:    v1.0.2
#>

<# SETUP - PLEASE READ BEFORE PANICKING
    Before this script can be run, you must set your execution policy to Remote Signed.
        - Run this command (no quotes) "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine"
        - You must respond yes (y) or all (a) in order to use this script.
        - Place this file wherever you like.
        - Run and login whenever you would like to use AD with your admin account.
        - Close the CMD window that appears with AD if you wish, it's just used to open the application.
    
    Once complete, modify the below code to generate your admin login from your normal account login.
    Then you can plug in your domain and you should be good to go!
#>

# Seperate first and last name.
$login = $env:USERNAME 
$pos = $login.IndexOf(".")
$firstName = $login.Substring(0, $pos)
$lastName = $login.Substring($pos+1)

# Format to admin login. Change this part to whatever format used in your environment. This is an example.
$adLogin = $firstName + $lastName.Substring(0,1) + '.admin'

Start-Process “C:\Windows\System32\cmd.exe” -workingdirectory $PSHOME -Credential "DOMAIN\$adLogin" -ArgumentList “/c dsa.msc”

# For testing, comment above line and uncomment block below.
<#
Write-Output $firstName
Write-Output $lastName
Write-Output $adLogin
#>