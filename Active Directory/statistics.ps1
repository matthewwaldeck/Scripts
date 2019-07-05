<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-04-2019
    Language:   PowerShell
    Purpose:    Gives you an overall look at your domain statistics.
    Last Edit:  07-04-2019
    Version:    v0.1.0
#>

# Enables AD commands
Import-Module ActiveDirectory


### Variables ###
$eUserCount = 0 #Enabled users
$dUserCount = 0 #Disabled users
$enabledUsers = Get-ADUser {-Filter enabled -eq $true}
$disabledUsers = Get-ADUser {-Filter enabled -eq $false}


### Functions ###
function Get-TimeStamp {
    return "{0:MM/dd/yy} at {0:HH:mm:ss}" -f (Get-Date)
}

# Gets number of enabled user accounts
function GetEnabledUsers {
    foreach ($_ in $enabledUsers) {
        $eUserCount = $eUserCount + 1
    }
}

# Gets number of disabled user accounts
function GetDisabledUsers {
    foreach ($_ in $disabledUsers) {
        $dUserCount = $dUserCount + 1
    }
}


### Script ###
"User: $env:USERNAME" | Set-Content C:\Users\$env:UserName\Desktop\Domain_Stats.log
"Time: $(Get-Timestamp)" | Add-Content C:\Users\$env:UserName\Desktop\Domain_Stats.log
"Domain: " + $domain | Add-Content C:\Users\$env:UserName\Desktop\Domain_Stats.log
GetEnabledUsers | Add-Content C:\Users\$env:UserName\Desktop\Domain_Stats.log
GetDisabledUsers | Add-Content C:\Users\$env:UserName\Desktop\Domain_Stats.log

pause