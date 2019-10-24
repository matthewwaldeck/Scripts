<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-12-2019
    Language:   PowerShell
    Purpose:    Launches all my usual apps in the morning, with the exceptin of AD and Citrix AppCenter (Require admin logins).
    Last Edit:  10-24-2019
    Version:    v1.2.0

    NOTES:
    -If you are going to use this script, please remember to disable "Launch on Startup" settings in each app.
    -Please also remember to update the work hours criteria with your normal work hours.
#>

# VARIABLES
$helpdeskURL = "http://phl-helpdesk:8080/WOListView.do"
#$dayStart = ""
#$dayEnd = ""

#This will be used to figure out if within working hours.
#Get-Date -Format "HH:mm"

# Google Chrome
start-process "chrome.exe" "$helpdeskURL"

# Microsoft Outlook
Start-Process 'C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE'

# Skype
Start-Process 'C:\Program Files (x86)\Microsoft Office\root\Office16\lync.exe'

# Microsoft Teams
Start-Process "C:\ProgramData\$env:USERNAME\Microsoft\Teams\Update.exe"

# TeamViewer
Start-Process 'C:\Program Files (x86)\TeamViewer\TeamViewer.exe'

# Remote Desktop Connection Manager
Start-Process 'C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe'