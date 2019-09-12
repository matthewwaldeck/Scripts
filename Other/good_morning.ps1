<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-12-2019
    Language:   PowerShell
    Purpose:    Launches all my usual apps in the morning, with the exceptin of AD and Citrix AppCenter (Require admin logins).
    Last Edit:  07-15-2019
    Version:    v1.1.0

    To-Do
    -Add time/date condition for starting apps
    -Have the script run whenever the computer is started
    -Add my AD and Citrix Receiver scripts to this, including a password prompt
#>

# Google Chrome
#Start-Process 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
start-process "chrome.exe" "http://phl-helpdesk:8080/WOListView.do", "https://community.spiceworks.com/", "https://www.theverge.com", "https://9to5mac.com/"

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

# GitHub Desktop
Start-Process "C:\ProgramData\$env:USERNAME\GitHubDesktop\GitHubDesktop.exe"

# Visual Studio Code
Start-Process "C:\Users\$env:USERNAME\AppData\Local\Programs\Microsoft VS Code\Code.exe"