<# DESCRIPTION
    Author:     Matt Waldeck
    Created:    05-18-2021
    Purpose:    Requests user info from domain controller.
    Last Edit:  05-18-2021
    Version:    v1.0.0
#>

# Asks for the user's name.
$name = Read-Host "What is the user's name?"

# Seperate first and last name.
$pos = $name.IndexOf(" ")
$first = $name.Substring(0, $pos)
$last = $name.Substring($pos+1)

# Generates command
net user "$first.$last" /domain

# Closes PS on keypress.
Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")