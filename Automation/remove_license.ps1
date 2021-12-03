<# DESCRIPTION
    Author:     Matt Waldeck
    Created:    12-03-2021
    Purpose:    Discovers the installed Office 365 license, and allows you to remove them easily.
    Last Edit:  12-03-2021
    Version:    v1.0.0
#>

# CONSTANTS AND VARIABLES #
$ErrorActionPreference = 'silentlycontinue'
$key = ""

# MAIN CODE #
Write-Host "`nLoading..."
#Checks for license keys currently installed on the system.
$info = cscript "$Env:Programfiles\Microsoft Office\Office16\OSPP.VBS" /dstatus

#Searches $info for the line containing the license key.
foreach ($item in $info){
    if ($item.SubString(0,17) -eq "Last 5 characters")
    {
        $key = $item.SubString(44,5)
    }
}

#Displays the last 5 of the key and asks the user if they would like to remove it.
Write-Host "The last 5 characters of your license are $key"
$remove = Read-Host "Would you like to remove the license? (yes/no)"
if ($remove.ToLower() -eq "yes")
{
    #Verification to protect against accidental deletion.
    $verify = Read-Host "Please verify license key to continue..."
    if ($verify.ToUpper() -eq $key)
    {
        Write-Host "Verification successful, removing key..."
        #This line will remove the license key from the system.
        cscript "$Env:Programfiles\Microsoft Office\Office16\OSPP.VBS" /unpkey:$key
        Write-Host "Done.`n"
    } else {
        Write-Host "Verification failed, exiting script...`n"
    }
} else {
    Write-Host "Cancelled, exiting script...`n"
}