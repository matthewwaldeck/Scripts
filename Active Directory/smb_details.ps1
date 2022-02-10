Clear-Host

$SmbServer = Read-Host "What is the name of your file server?"
$Cim = New-CimSession -ComputerName $SmbServer
$SmbShares = Get-SmbShare -CimSession $Cim
$Search = Read-Host "Search"

Write-Host ""

foreach ($SmbShare in $SmbShares) {
    if ($SmbShare.Name -imatch $Search) {
        Write-Host "--------------------------------------------"

        $Path = "\\" + $SmbServer + "\"+ $SmbShare.Name

        Write-Host "Path:"
        Write-Host $Path -ForegroundColor Red -BackgroundColor Black
        Write-Host ""

        $PermissionsACL = Get-Acl -Path $Path

        foreach ($Identity in $PermissionsACL) {
            foreach ($AccessRight in $Identity.Access) {
                $Object = $AccessRight.IdentityReference

                if ($Object -inotmatch "Domain Admins") {
                    $SamAccountName = $Object.Value.Split('\')[1]
                    $ADObject = Get-ADObject -Filter ('SamAccountName -eq "{0}"' -f $SamAccountName)
                    if ($ADObject.ObjectClass -eq 'group') {
                        Write-Host "Group:"
                        Write-Host $Object -ForegroundColor Green -BackgroundColor Black
                        Write-Host ""
                        Write-Host "Permissions:"
                        Write-Host $AccessRight.FileSystemRights -ForegroundColor Blue -BackgroundColor Black
                        Write-Host ""
                    }
                }
            }
        }
    }
}