cls
#information about the System
$system = Get-WMIObject -Class Win32_ComputerSystem
'System'
'Manufacturer: ' + $system.Manufacturer
'Model: ' + $system.Model
'Name: ' + $system.Name
'Domain: ' + $system.Domain
'Memory: ' + $system.TotalPhysicalMemory


''
#BIOS information
$bios = Get-WmiObject -Class Win32_BIOS
'BIOS'
'Computer Name: ' + $bios.PSComputerName
'Manufacturer: ' + $bios.Manufacturer
'BIOS Version: ' + $bios.SMBIOSBIOSVersion


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
Get-PSDrive | Where-Object {$_.Provider.Name -eq "FileSystem"}


''
#Network configuration details
'Network'
$network = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE)
foreach ($_ in $network) {
     'Name: ' + $_.Description
     'IP Address: ' + $_.IPAddress
     ''
}