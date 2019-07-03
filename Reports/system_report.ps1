<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-27-2019
    Language:   PowerShell
    Purpose:    Lists basic system info.
    Last Edit:  06-28-2019
    Version:    v1.0.1
#>

#Getting some information
$date = Get-Date -Format g
$system = Get-WMIObject -Class Win32_ComputerSystem
$os = Get-CimInstance -Class Win32_OperatingSystem
$bios = Get-WmiObject -Class Win32_BIOS
$cpu = Get-WMIObject -Class Win32_Processor
$network = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE)
$storage = (Get-WmiObject -Class Win32_logicaldisk)

#information about the System
'System'
'Name: ' + $system.Name
"Today's Date: " + $date
'Current User: ' + $env:UserName
'Manufacturer: ' + $system.Manufacturer
'Model: ' + $system.Model
'OS: ' + $os.Caption
'Serial Number: ' + $os.SerialNumber
'Architecture: ' + $os.osarchitecture
'Domain: ' + $system.Domain
'BIOS Manufacturer: ' + $bios.Manufacturer
'BIOS Version: ' + $bios.Version
'Memory: ' + [math]::Round($system.TotalPhysicalMemory / 1GB,1) + 'GB'
foreach ($_ in $cpu) {
    'Number: ' + $cpu.DeviceID
    'Model: ' + $cpu.Name
    }

''
#Network configuration details
'Network'
foreach ($_ in $network) {
    'Name: ' + $_.Description
    'IP Address: ' + $_.IPAddress
    'Gateway: ' + $_.DefaultIPGateway
    'DHCP?: ' + $_.DHCPEnabled
    ''
}

''
#Information about Logical Drives (Includes mapped drives and I believe PSDrives)
'Storage'
#Get-PSDrive | Where-Object {$_.Provider.Name -eq "FileSystem"}
foreach ($_ in $storage) {
    'Label: ' + $_.DeviceID + '\'
    if ($_.VolumeName -ne '') {
       'Name: ' + $_.VolumeName
    }
    'Capacity: ' + [math]::Round($_.Size / 1GB,2) + 'GB'
    'Used: ' + [math]::Round(($_.Size - $_.FreeSpace) / 1GB,2) + 'GB'
    'Free: ' + [math]::Round($_.FreeSpace / 1GB,2) + 'GB'
    ''
}