<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-12-2019
    Language:   PowerShell
    Purpose:    Launches all my usual apps in the morning, with the exceptin of AD and Citrix AppCenter (Require admin logins).
    Last Edit:  10-24-2019
    Version:    v2.0.0

    NOTES:
    -If you are going to use this script, please remember to disable "Launch on Startup" settings in each app.
    -Please also remember to update the work hours criteria with your normal work hours.
    -You can add more websites to auto-open with Chrome in a comma-seperated list
        -ie. start-process "chrome.exe" "$helpdeskURL", "https://news.google.com", https://www.theverge.com
#>

# VARIABLES
$helpdeskURL = "http://phl-helpdesk:8080/WOListView.do"
$dayStart = "09" #Must be in 24h format
$dayEnd = "17" #Must be in 24h format

# SCRIPT
$time = Get-Date -Format "HH"
if ($time -eq $dayStart -and $time -lt $dayend) {
    launchApps
}

# FUNCTIONS
function launchApps {
    start-process "chrome.exe" "$helpdeskURL" #Chrome with helpdesk open
    Start-Process 'C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE' #Outlook
    Start-Process 'C:\Program Files (x86)\Microsoft Office\root\Office16\lync.exe' #Skype
    Start-Process "C:\ProgramData\$env:USERNAME\Microsoft\Teams\Update.exe" #Teams
    Start-Process 'C:\Program Files (x86)\TeamViewer\TeamViewer.exe' #TeamViewer
    Start-Process 'C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe' #RDP
}