<#
    .NOTES        
        NAME:    timesync.ps1
        AUTHOR:  Matt Waldeck
        VERSION: 1.1.0
        DATE:    2023/12/05
        LINK:    https://github.com/Gediren/Windows-Scripts/blob/master/Automation/timesync.ps1

        VERSION HISTORY
            1.0.0 - 2023.12.05
                Initial Version.
            1.1.0 - 2023.12.05
                Fixed typo in notes.
                Improved documentation.
                Added response check for $update, with loop.
                Added catch for lack of access.
    
    .SYNOPSIS
        Update Windows time server.

    .DESCRIPTION
        This script will update the server Windows system clock is syncing to.
        It will present the current time server, and ask if the admin would like to update to NTP.

    .INPUTS
        None. You cannot pipe objects to this script.

    .OUTPUTS
        None. This script does not generate any output.

    .LINK
        https://github.com/Gediren/
#>

#Display current time source.
$current = ""
$current = w32tm /query /source
if ($current -like "*Access is denied*") {
    Write-Host "You do not have the proper access."
    Write-Host "Please rerun the script in an elevated shell."
    Read-Host -Prompt “Press enter to continue”
    #exit
} else {
    Write-Host "The clock is synced to $current."
}

#Wait a few before proceeding.
sleep -Seconds 2

Do {
    $loop = 0
    $update = ""
    
    #Ask if the time source should be updated.
    $update = Read-Host -Prompt "Would you like to update to NTP? (y/n)"
    if ($update -like 'y') {
        try {
            #Update time source to use NTP pool.
            w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"
            w32tm /update
            Write-Host "Time has been updated to use the NTP pool."
        } catch {Write-Host "The update failed. You are still using $current."}
        $loop ++
    } elseif ($update -like 'n') {
        Write-Host "No changes have been made."
        $loop ++
    } else {
        Write-Host "Invalid selection."

    }
} while ($loop -eq 0)