<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-28-2019
    Language:   PowerShell
    Purpose:    Renames large amounts of files. Not yet tested.
    Last Edit:  07-02-2019
    Version:    v0.1.0
#>

#Directory to be scanned.
cd #DIRECTORY

#This will pipe all the files in your current directory
#into Rename-Item, and replace whatever is in the first
#set of quotes withwhatever is in the second.
Dir | Rename-Item –NewName { $_.name –replace “ “,”_” }