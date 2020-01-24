<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-12-2019
    Language:   PowerShell
    Purpose:    Launches all my usual apps in the morning. Place shortcut on desktop and run once logged in.
    Last Edit:  01-24-2020
    Version:    v3.0.1
#>


# VARIABLES & URLS
#$intranetURL = "http://intranet.company.com/"
$helpdeskURL = "http://helpdesk.company.com/"


Write-Host "Launching Apps..."
Start-Process "C:\Program Files (x86)\Telephony\TouchPoint\TouchPoint.exe" #TouchPoint
Start-Sleep -Seconds 30 #Delayed to give Touchpoint time to load.
Start-Process "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" "$helpdeskURL" #Chrome
Start-Sleep -Seconds 10
Start-Process "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE" #Outlook
Write-Host "Done."
Start-Sleep -Seconds 10
Exit