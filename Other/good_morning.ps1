<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-12-2019
    Language:   PowerShell
    Purpose:    Launches all my usual apps in the morning, but only during work hours. This ensures that if my laptop is turned on outside of work hours
                it doesn't instantly load my entire suite of apps. This saves battery life and improves performance when working away from my desk.
    Last Edit:  10-24-2019
    Version:    v2.1.0

    NOTES:
    -If you are going to use this script, please remember to disable "Launch on Startup" settings in each app.
    -Please also remember to update the work hours criteria with your normal work hours.
    -You can add more websites to auto-open with Chrome by adding to the comma seperated list.
#>

# VARIABLES & URLs
$intranetURL = "http://daily.cowangroup.ca/EN/Pages/default.aspx"
$helpdeskURL = "http://phl-helpdesk:8080/WOListView.do"
$dayStart = "09" #Start of work day. Must be in 24h format
$dayEnd = "17" #End of work day. Must be in 24h format

# FUNCTIONS
function launchApps {
    Write-Host "Launching Apps..."
    start-process 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' "$intranetURL", "$helpdeskURL" #Chrome with intranet site and helpdesk open
    Start-Process 'C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE' #Outlook
    Start-Process 'C:\Program Files (x86)\Microsoft Office\root\Office16\lync.exe' #Skype
    # !!!NOT FUNCTIONAL!!! Start-Process "C:\ProgramData\$env:USERNAME \Microsoft\Teams\Update.exe" #Teams
    Start-Process 'C:\Program Files (x86)\TeamViewer\TeamViewer.exe' #TeamViewer
    Start-Process 'C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe' #RDP
    Write-Host "Done."
}

# SCRIPT
$time = Get-Date -Format "HH"
if (($time -ge $dayStart) -and ($time -lt $dayEnd)) {
    launchApps
}