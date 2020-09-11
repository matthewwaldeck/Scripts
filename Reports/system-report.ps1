<#
    DESCRIPTION
    Developer:  Matt Waldeck
    Date:       06-27-2019
    Purpose:    Lists basic system info.
    Last Edit:  09-11-2020
    Version:    v1.1.2
#>

#Getting some information
$date = Get-Date -Format g
$system = Get-WMIObject -Class Win32_ComputerSystem
$os = Get-CimInstance -Class Win32_OperatingSystem
$bios = Get-WmiObject -Class Win32_BIOS
$cpu = Get-WMIObject -Class Win32_Processor
$network = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE)
$storage = (Get-WmiObject -Class Win32_logicaldisk)

function intro {
    "System report requested by $env:USERNAME on $date."
    ''
}

#Information about the System
function system {
    'System'
    'Name: ' + $system.Name
    'OS: ' + $os.Caption
    'Serial Number: ' + $os.SerialNumber
    'Architecture: ' + $os.osarchitecture
    'Domain: ' + $system.Domain
    'BIOS Manufacturer: ' + $bios.Manufacturer
    'BIOS Version: ' + $bios.Version
    ''
}

#Hardware details
function hardware {
    'Hardware'
    'Manufacturer: ' + $system.Manufacturer
    'Model: ' + $system.Model
    'Memory: ' + [math]::Round($system.TotalPhysicalMemory / 1GB,1) + 'GB'
    foreach ($_ in $cpu) {
        'CPU Number: ' + $cpu.DeviceID
        'CPU Model: ' + $cpu.Name
    }
    ''
}

#Network configuration details
function network {
    'Network'
    foreach ($_ in $network) {
        'Name: ' + $_.Description
        'IP Address: ' + $_.IPAddress
        'Gateway: ' + $_.DefaultIPGateway
        'DHCP Enabled?: ' + $_.DHCPEnabled
        ''
    }
    ''
}

#Information about Logical Drives
function storage {
    'Storage'
    #Get-PSDrive | Where-Object {$_.Provider.Name -eq "FileSystem"}
    foreach ($_ in $storage) {
        'Drive: ' + $_.DeviceID + '\'
        if ($_.VolumeName -ne '') {
        'Name: ' + $_.VolumeName
        }
        'Capacity: ' + [math]::Round($_.Size / 1GB,2) + 'GB'
        'Used: ' + [math]::Round(($_.Size - $_.FreeSpace) / 1GB,2) + 'GB'
        'Free: ' + [math]::Round($_.FreeSpace / 1GB,2) + 'GB'
        ''
    }
}


### Script ###
$logFile = "C:\Users\$env:USERNAME\Desktop\$env:COMPUTERNAME.txt"
intro | Set-Content $logFile
system | Add-Content $logFile
hardware | Add-Content $logFile
network | Add-Content $logFile
storage | Add-Content $logFile
Write-Output "File written to C:\Users\$env:USERNAME\Desktop\$env:COMPUTERNAME.txt"
''