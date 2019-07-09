<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-08-2018
    Language:   PowerShell
    Purpose:    Downloads an offline archive of all Questionable Content comics.
    Last Edit:  07-09-2019
    Version:    v1.0.1

    NOTE:
        For regular viewing please go to the website as it supports the artist,
        this only exists to create an offline backup in case the site goes down.
#>

# Update $last to match the number of the last comic uploaded.
$count = 1
$last = 4041 + 1

# Questionable Content
while ($count -lt $last) {
    $url = "https://questionablecontent.net/comics/$count.png"
    Invoke-WebRequest $url -OutFile C:\Users\$env:USERNAME\Documents\questionable_content\$count.png
    $count=$count+1
}

# Lets you know it's finished downloading.
Write-Output "Successfully downloaded QC archive!"
Pause