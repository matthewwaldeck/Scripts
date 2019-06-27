cls
#The basics
$date = Get-Date -Format g
'Current User: ' + $env:UserName
"Today's Date: " + $date

''
''
#information about the System
'System'
$system = Get-WMIObject -Class Win32_ComputerSystem
'Manufacturer: ' + $system.Manufacturer
'Model: ' + $system.Model
'Name: ' + $system.Name
'Domain: ' + $system.Domain
'Memory: ' + [math]::Round($system.TotalPhysicalMemory / 1GB,1) + 'GB'


''
''
#BIOS information
'BIOS'
$bios = Get-WmiObject -Class Win32_BIOS
'Computer Name: ' + $bios.PSComputerName
'Manufacturer: ' + $bios.Manufacturer
'BIOS Version: ' + $bios.SMBIOSBIOSVersion


''
''
#CPU specifications
'Processor'
$network = ($cpu = Get-WMIObject -Class Win32_Processor)
foreach ($_ in $cpu) {
    'Number: ' + $cpu.DeviceID
    'Manufacturer: ' + $cpu.Manufacturer
    'Model: ' + $cpu.Name
    'Speed: ' + $cpu.MaxClockSpeed
    ''
}


''
#Information about Logical Drives (Includes mapped drives and I believe PSDrives)
'Storage'
#Get-PSDrive | Where-Object {$_.Provider.Name -eq "FileSystem"}
$storage = (Get-WmiObject -Class Win32_logicaldisk)
foreach ($_ in $storage) {
    'Label: ' + $_.DeviceID
    if ($_.VolumeName -ne '') {
       'Name: ' + $_.VolumeName
    }
    'Capacity: ' + [math]::Round($_.Size / 1GB,2) + 'GB'
    'Used: ' + [math]::Round(($_.Size - $_.FreeSpace) / 1GB,2) + 'GB'
    'Free: ' + [math]::Round($_.FreeSpace / 1GB,2) + 'GB'
    ''
}


''
#Network configuration details
'Network'
$network = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE)
foreach ($_ in $network) {
    'Name: ' + $_.Description
    'IP Address: ' + $_.IPAddress
    ''
}