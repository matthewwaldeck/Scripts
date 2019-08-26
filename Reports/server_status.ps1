<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       08-26-2019
    Language:   PowerShell
    Purpose:    Pulls server list from text file, and pings each server. If successful, logs that server is online.
    Last Edit:  08-26-2019
    Version:    v0.1.0
#>

$ErrorActionPreference = 'silentlycontinue'
$logPath = "C:\Users\$env:USERNAME\Documents\server_status_$(get-date -f yyyy-MM-dd-HHmm).log"
Write-Output "Writing files to C:\Users\$env:USERNAME\Documents..."

#Variable init.
$test = 0

#Functions
function dirtywork {
    if (test-path C:\Users\$env:USERNAME\Documents\servers.txt -eq $False) {
        New-Item C:\Users\$env:USERNAME\Documents\servers.txt
        $test = 0
        Write-Host "Eveything is set up, now go put some servers in the text file I created and I'll see if they're online."
        "Eveything is set up, now go put some servers in the text file I created and I'll see if they're online." | Set-Content $logPath
    } else {
        $test = 1
        Write-Host "Running tests..."
    }
}

function test {
    $servers = Get-Content C:\Users\$env:USERNAME\Documents\servers.txt
    foreach ($_ in $servers) {
        ping $_
    }
}


#Script
dirtywork
if ($test -eq 1) {
    test
}