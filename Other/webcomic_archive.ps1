<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-08-2018
    Language:   PowerShell
    Purpose:    Downloads a copy of my favourite Webcomics, primarily for archival purposes.
    Last Edit:  07-24-2019
    Version:    v2.0.2

    Comics:
        -Questionable Content
        -XKCD (Coming Soon-ish)

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
Write-Output "Writing files to C:\Users\$env:USERNAME\Documents\Webcomics..."

#Global variables for tracking number of items downloaded
$download=0
$download_qc=0
$download_xkcd=0


# FUNCTIONS #
function dirty_work {
    #Ensures creation of file structure
    New-Item -Path C:\Users\$env:USERNAME\Documents\Webcomics\questionable_content -ItemType Directory | Out-Null
    New-Item -Path C:\Users\$env:USERNAME\Documents\Webcomics\XKCD\ -ItemType Directory | Out-Null

    #Create log file in webcomic root
    "Archive started by $env:USERNAME on $(Get-TimeStamp)" | Set-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    "Writing files to C:\Users\$env:USERNAME\Documents\Webcomics." | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    '' | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
}

function Get-TimeStamp {
    return "{0:MM/dd/yy} at {0:HH:mm:ss}" -f (Get-Date)
}

function questionable_content {
    #Questionable Content by Jeph Jacques
    #https://questionablecontent.net/
    $comic=1
    $err=0

    "Downloading Questionable Content by Jeph Jacques..." | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    "Started on $(Get-TimeStamp)" | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log

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
    "Completed on $(Get-TimeStamp)" | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    "Downloaded $download_qc items with $err errors." | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    "Total Comics: $comic" | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    "Total filesize: $size" | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    '' | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
}

function xkcd {
    #XKCD by Randall Munroe
    #https://xkcd.com/
    $id
    $comic=1
    $err=0

    "Downloading XKCD by Randall Munroe..." | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    "Started on $(Get-TimeStamp)" | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log

    while ($err -lt 5) {
        $path = Test-Path -Path "C:\Users\$env:USERNAME\Documents\Webcomics\XKCD\$comic_$id.png"
        if ($path -eq $False) {
            try {
                $url = "https://questionablecontent.net/comics/$comic.png"
                Invoke-WebRequest $url -OutFile C:\Users\$env:USERNAME\Documents\Webcomics\xkcd\$comic_$id.png
                $err=0
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
    $size = "{0:N2} MB" -f ((Get-ChildItem C:\Users\$env:USERNAME\Documents\Webcomics\questionable_content | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
    "Completed on $(Get-TimeStamp)" | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    "Downloaded $download_qc items with $err errors." | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    "Total Comics: $comic" | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    "Total filesize: $size" | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
    '' | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
}

# SCRIPT #
dirty_work
questionable_content

# LOGGING & OUTPUT #
Write-Output "Log written to C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log"
Write-Output "Archive complete!"
Write-Output ''
"Downloaded a total of $download items." | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log
"Archive completed on $(Get-TimeStamp)" | Add-Content -Path C:\Users\$env:USERNAME\Documents\Webcomics\webcomic_archive.log