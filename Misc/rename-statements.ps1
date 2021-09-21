<# DESCRIPTION
    Author:     Matt Waldeck
    Created:    09-21-2021
    Purpose:    Remove extraneous text from Cowan pay statement filenames.
    Last Edit:  09-21-2021
    Version:    v1.0.0
#>

Set-Location Downloads
Get-ChildItem -Filter "*current*" -Recurse | Rename-Item -NewName {$_.name -replace 'EmployeePayStatementsDeposits ','' }
Get-ChildItem | Rename-Item -NewName {$_.name.substring(0,$_.BaseName.length-4) + $_.Extension}