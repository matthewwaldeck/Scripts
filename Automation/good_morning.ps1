<#
    DESCRIPTION
    Author:     Matt Waldeck
    Created:    12-07-2020
    Purpose:    Automates the basic setup process for a new Windows PC.
    Last Edit:  02-25-2020
    Version:    1.0.0
#>

# VARIABLES & URLS
$url_intranet = "daily.cowangroup.ca/EN/Pages/default.aspx"
$url_helpdesk = "http://phl-helpdesk:8080/WOListView.do"

#Launch programs
Write-Host "Launching Apps..."
Start-Process "C:\Program Files (x86)\Telephony\TouchPoint\TouchPoint.exe" #TouchPoint
Start-Sleep -Seconds 30 #Delayed to give Touchpoint time to load.
Start-Process "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" "$url_intranet, $url_helpdesk" #Chrome
Start-Sleep -Seconds 10
Start-Process "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE" #Outlook
Write-Host "Done."
Start-Sleep -Seconds 10
Exit