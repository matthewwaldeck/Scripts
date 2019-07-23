<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-08-2018
    Language:   PowerShell
    Purpose:    Downloads a copy of my favourite webcmics, primarily for archival purposes.
    Last Edit:  07-23-2019
    Version:    v1.1.0

    Comics:
        -Questionable Content
        -XKCD (Coming Soon)

    NOTE:
        For regular viewing please go to the website as it supports the artist,
        this only exists to create an offline backup in case the sites go down.
#>

New-Item -Path C:\Users\$env:USERNAME\Documents\webcomics\questionable_content -ItemType directory

#Questionable Content by Jeph Jacques
#https://questionablecontent.net/
function questionable_content {
#Replace basically this whole code block with an error check?
#Start at comic #1, and when you receive an error stop.
#Will have to come up with a way to ignore missing comics.

    $count = 4052
    
    while ($count -gt 0) {
        $url = "https://questionablecontent.net/comics/$count.png"
        Invoke-WebRequest $url -OutFile C:\Users\$env:USERNAME\Documents\webcomics\questionable_content\$count.png
        $count=$count-1
    }
}

#Run the script
questionable_content
Write-Output "Archive complete!"