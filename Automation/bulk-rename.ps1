<# DESCRIPTION
    Author:     Matt Waldeck
    Created:    09-22-2021
    Purpose:    Remove extraneous text from filenames.
    Last Edit:  09-22-2021
    Version:    v1.0.0
#>

$ErrorActionPreference = 'silentlycontinue'
Write-Host "`nWhere are the files you would like to rename?`nPlease provide a full path."
$path = Read-Host
try {
    Set-Location $path
}
catch {
    Write-Host "Error: Path not valid!"
    Start-Sleep -Seconds 5
    Exit
}

$old = Read-Host "What would you like to change?"
$new = Read-Host "What should I replace it with?"

Write-Host "Updating filenames..."
try {
    Get-ChildItem | Rename-Item -NewName {$_.name -replace $old,$new}
}
catch {
    Write-Host "Error: Failed to rename files!"
    Start-Sleep -Seconds 5
    Exit
}
#Get-ChildItem | Rename-Item -NewName {$_.name.substring(0,$_.BaseName.length-4) + $_.Extension}
Write-Host "Done!"
Start-Sleep -Seconds 3