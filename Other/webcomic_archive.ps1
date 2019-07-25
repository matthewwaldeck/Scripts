<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-08-2018
    Language:   PowerShell
    Purpose:    Downloads a copy of my favourite Webcomics, primarily for archival purposes.
    Last Edit:  07-24-2019
    Version:    v2.1.0

    Comics:
        -Questionable Content
        -XKCD

    What's New:
        -Rewrote script utilizing functions for easy expansion.
        -Removed the need to manually set the number of the most recent QC comic. Script is now fully automated.
        -Now checks to see if comics already exist, and if so it does not redownload them.
        -Provides statistics in log file when complete.

    NOTE:
        For regular viewing please go to the website as it supports the artist, this only exists to
        create an offline backup in case the sites go down. This would be a great thing to run as
        an automatic weekly or daily task on a storage server.
#>

$ErrorActionPreference = 'silentlycontinue'
$logPath = "C:\Users\$env:USERNAME\Documents\Webcomics\logs\webcomic-archive_$(get-date -f yyyy-MM-dd).log"
Write-Output "Writing files to C:\Users\$env:USERNAME\Documents\Webcomics..."

#Global variables for tracking number of items downloaded
$download=0
$download_qc=0
$download_xkcd=0


# FUNCTIONS #
function dirty_work {
    #Ensures creation of file structure
    New-Item -Path C:\Users\$env:USERNAME\Documents\Webcomics\logs\ -ItemType Directory | Out-Null
    New-Item -Path C:\Users\$env:USERNAME\Documents\Webcomics\questionable_content\ -ItemType Directory | Out-Null
    New-Item -Path C:\Users\$env:USERNAME\Documents\Webcomics\xkcd\ -ItemType Directory | Out-Null

    #Create log file in webcomic root
    "Archive started by $env:USERNAME on $(Get-TimeStamp)" | Set-Content -Path $logPath
    "Writing files to C:\Users\$env:USERNAME\Documents\Webcomics." | Add-Content -Path $logPath
    '' | Add-Content -Path $logPath
}

function Get-TimeStamp {
    return "{0:MM/dd/yy} at {0:HH:mm:ss}" -f (Get-Date)
}

function questionable_content {
    #Questionable Content by Jeph Jacques
    #https://questionablecontent.net/
    $comic=1
    $err=0

    "Downloading Questionable Content by Jeph Jacques..." | Add-Content -Path $logPath
    "Started on $(Get-TimeStamp)" | Add-Content -Path $logPath

    while ($err -lt 5) {
        $path = Test-Path -Path "C:\Users\$env:USERNAME\Documents\Webcomics\questionable_content\$comic.png"
        if ($path -eq $False) {
            try {
                $url = "https://questionablecontent.net/comics/$comic.png"
                Invoke-WebRequest $url -OutFile C:\Users\$env:USERNAME\Documents\Webcomics\questionable_content\$comic.png
                $err=0
                $download=$download+1
                $download_qc=$download_qc+1
            } catch {
                $err=$err+1
            }
        } else {
            $err=0
        }
        $comic=$comic+1
    }
    $comic = $comic-6
    $size = "{0:N2} MB" -f ((Get-ChildItem C:\Users\$env:USERNAME\Documents\Webcomics\questionable_content | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
    "Completed on $(Get-TimeStamp)" | Add-Content -Path $logPath
    "Downloaded $download_qc items with $err errors." | Add-Content -Path $logPath
    "Total Comics: $comic" | Add-Content -Path $logPath
    "Total filesize: $size" | Add-Content -Path $logPath
    '' | Add-Content -Path $logPath
}

function xkcd {
    #XKCD by Randall Munroe
    #https://xkcd.com/
    $comic=1
    $err=0
    $title=''

    #Step 1: http://xkcd.com/$comic/info.0.json
    #Step 2: Find "img:" tag
    #Step 3: Use URL to download comic

    "Downloading XKCD by Randall Munroe..." | Add-Content -Path $logPath
    "Started on $(Get-TimeStamp)" | Add-Content -Path $logPath

    while ($err -lt 5) {
        $path = Test-Path -Path "C:\Users\$env:USERNAME\Documents\Webcomics\xkcd\$comic. $title"
        if ($path -eq $False) {
            try {
                $json = Invoke-WebRequest "http://xkcd.com/$comic/info.0.json" | ConvertFrom-Json
                $url = $json.img
                $title = $json.title
                Invoke-WebRequest $url -OutFile "C:\Users\$env:USERNAME\Documents\Webcomics\xkcd\$comic. $title.png"
                $download=$download+1
                $download_xkcd=$download_xkcd+1
            } catch {
                $err=$err+1
            }
        } else {
            $err=0
        }
        $comic=$comic+1
    }
    $comic = $comic-6
    $size = "{0:N2} MB" -f ((Get-ChildItem C:\Users\$env:USERNAME\Documents\Webcomics\xkcd | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
    "Completed on $(Get-TimeStamp)" | Add-Content -Path $logPath
    "Downloaded $download_xkcd items with $err errors." | Add-Content -Path $logPath
    "Total Comics: $comic" | Add-Content -Path $logPath
    "Total filesize: $size" | Add-Content -Path $logPath
    '' | Add-Content -Path $logPath
}

# SCRIPT #
dirty_work
questionable_content
xkcd

# LOGGING & OUTPUT #
$size = "{0:N2} MB" -f ((Get-ChildItem C:\Users\$env:USERNAME\Documents\Webcomics\xkcd | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
Write-Output "Log written to $logpath"
Write-Output "Archive complete!"
Write-Output ''
"Downloaded a total of $download items." | Add-Content -Path $logPath
"Total filesize of archive: $size" | Add-Content -Path $logPath
"Archive completed on $(Get-TimeStamp)" | Add-Content -Path $logPath