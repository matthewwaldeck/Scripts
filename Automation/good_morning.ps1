<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-12-2019
    Language:   PowerShell
    Purpose:    Launches all my usual apps in the morning. Place shortcut on desktop and run once logged in.
    Last Edit:  01-21-2020
    Version:    v3.0.0
#>


# VARIABLES & URLS
#$intranetURL = "http://daily.cowangroup.ca/EN/Pages/default.aspx" #Uncomment and update for company Intranet site
$helpdeskURL = "http://phl-helpdesk:8080/WOListView.do"


# FUNCTIONS
function launchApps {
    Write-Host "Launching Apps..."
    Start-Process "C:\Program Files (x86)\Telephony\TouchPoint\TouchPoint.exe" #TouchPoint, delayed to fix startup performance.
    Start-Sleep -Seconds 30
    start-process "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" "$helpdeskURL" #Chrome
    Start-Sleep -Seconds 10
    Start-Process "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE" #Outlook
    Write-Host "Done."
    Start-Sleep -Seconds 10
    Exit
}


# SCRIPT
launchApps