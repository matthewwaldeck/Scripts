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
# Still need to code some output.
# Ideally will put a text file in the current user's Documents folder I think.
# Once I get a test environment set up I can see if this even works.
# That sounds like a project for tomorrow...
GetEnabledUsers
GetDisabledUsers