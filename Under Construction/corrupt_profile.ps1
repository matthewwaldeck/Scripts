<#
    .NOTES               
        NAME:    corrupt_profile.ps1
        AUTHOR:  Matt Waldeck
        VERSION: 0.2.0
        DATE:    2023/12/05
        LINK:    https://github.com/Gediren/Windows-Scripts/blob/master/Under Construction/corrupt_profile.ps1

        VERSION HISTORY
            0.1.0 - 2023.11.09
            0.2.0 - 2023.12.05
                Updated help/description.
                Continued troubleshooting issues.
    
    .SYNOPSIS
        This script will attempt to fix a corrupted user profile.

    .DESCRIPTION
        This script will attempt to fix a corrupted user profile.
        After running, the user should be able to simply log back in as themselves.
        At which point, it will create a new profile and allow them to grab their files and get back to normal.

    .INPUTS
        None. You cannot pipe objects to this script.

    .OUTPUTS
        None. This script does not generate any output.

    .LINK
        https://github.com/Gediren/
#>

#Prompt for username to be recovered.
$username = Read-Host -Prompt "What is the username to be repaired? Leave blank for current user."
$date = Get-Date -Format "yyyy/MM/dd"


#Back up the registry, specifically HKLM where we will be making changes.
mkdir C:\Users\$env:USERNAME\Documents\Registry_Backup
reg export HKLM C:\Users\$env:USERNAME\Documents\Registry_Backup\hklm_$date.reg

if ($username -ne "") {
    #Create variables based on input.
    $user_original = "C:\Users\$username"
    $user_backup = "C:\Users\$username.BAK"
} else {
    #Default to current user if blank.
    $user_original = "C:\Users\$env:USERNAME"
    $user_backup = "C:\Users\$env:USERNAME.BAK"
}

#Rename user profile folder.
Rename-Item $user_original $user_backup

#Get USID.
#This doesn't work and I don't understand why.
$usid = Invoke-Command -ScriptBlock {wmic useraccount where name="mwaldeck" get sid}
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$usid"

#Check if the registry key exists.
if (Test-Path -Path $regPath) {
    try {
        #Remove-Item -Path $regPath -force
        Write-Host "Registry key $usid deleted."
    } Catch {
        Write-error $_
    }
} else {Write-Host "Registry key $usid does not exist."}

#Log out current user.
logoff
