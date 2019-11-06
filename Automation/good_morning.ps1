<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-12-2019
    Language:   PowerShell
    Purpose:    Launches all my usual apps in the morning, but only during work hours. This saves battery life and improves performance when working
                from home by not auto-starting everything on my laptop.
    Last Edit:  11-6-2019
    Version:    v2.2.3

    SETUP
    -Create a task in Task Schduler to be run when you log into your account
    -Set up an action with the following settings
        -Program = powershell.exe
        -Arguments = .\good_morning.ps1
        -Start in = path to wherever you put this script (i.e. C:\Scripts)
    -Under the Conditions tab, disable AC power condition

    NOTES
    -If you are going to use this script, please remember to disable "Launch on Startup" settings in each app.
    -Please also remember to update the work hours criteria with your normal work hours.
    -You can add more websites to auto-open with Chrome by adding to the comma seperated list.
    -$dayStart should be the hour before you start work, in case you come in early.
    -Please feel free to let me know if there are any apps you would like added and I will happily add them.
#>


# VARIABLES & URLs
$intranetURL = "http://daily.cowangroup.ca/EN/Pages/default.aspx"
$helpdeskURL = "http://phl-helpdesk:8080/WOListView.do"
$dayStart = "07" #Start of work day. Must be in 24h format. Default is 7am.
$dayEnd = "17" #End of work day. Must be in 24h format. Default is 5pm.


# FUNCTIONS
function launchApps {
    #Uncomment lines to enable individual apps. I'll be adding popular applications over time.
    Write-Host "Launching Apps..."
    start-process "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" "$intranetURL", "$helpdeskURL" #Chrome with intranet site and helpdesk open
    Start-Process "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE" #Outlook
    Start-Process "C:\Program Files (x86)\Microsoft Office\root\Office16\lync.exe" #Skype
    Start-Process "C:\ProgramData\$env:USERNAME\Microsoft\Teams\current\teams.exe" #Teams
    Start-Process "C:\Program Files (x86)\Telephony\TouchPoint\TouchPoint.exe" #TouchPoint
    #Start-Process "C:\Program Files (x86)\TeamViewer\TeamViewer.exe" #TeamViewer
    #Start-Process "C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe" #RDP
    Write-Host "Done."
    Start-Sleep -Seconds 5
}


# SCRIPT
$time = Get-Date -Format "HH"
$day = Get-Date -Format "dddd"
if (($day -ne "Saturday") -or ($day -ne "Sunday")) {
    if (($time -ge $dayStart) -and ($time -lt $dayEnd)) {
        launchApps
    }
}