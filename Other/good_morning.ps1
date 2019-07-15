<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-12-2019
    Language:   PowerShell
    Purpose:    Launches all my usual apps in the morning.
    Last Edit:  07-15-2019
    Version:    v1.1.0

    Note:
        The only reason I use this instead of the startup menu in Task Manager is because I take my laptop home with me,
        and if I work on something at home I don't necessarily want everything open that I usually do on my average day.
#>

# Google Chrome
#Start-Process 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
start-process "chrome.exe" "http://phl-helpdesk:8080/WOListView.do", "https://community.spiceworks.com/", "https://www.theverge.com"

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