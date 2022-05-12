<# DESCRIPTION
    Author:     Matt Waldeck
    Created:    12-05-2022
    Purpose:    Kills a stuck session on a terminal server.
    Last Edit:  12-05-2022
    Version:    v1.0.0

    WORK IN PROGRESS, HAS NOT FINISHED TESTING.
#>

$serverName = $env:COMPUTERNAME
$sessions = qwinsta /server:$serverName
foreach ($_ in $sessions) {
    $user = $_.USERNAME
    $id = $_.id

    Write-Host "Session $id : $user"
}

$sessionID = Read-Host "Which session would you like to kill?"
rwinsta /server:$serverName $sessionID