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
#Information about the BIOS
$bios = Get-WmiObject -Class Win32_BIOS
'BIOS'
'Computer Name: ' + $bios.PSComputerName
'Manufacturer:  ' + $bios.Manufacturer
'BIOS Version:  ' + $bios.SMBIOSBIOSVersion

''
#Information about the CPU
$cpu = Get-WMIObject -Class Win32_Processor
'Processor'
'Number: ' + $cpu.DeviceID
'Manufacturer: ' + $cpu.Manufacturer
'Model: ' + $cpu.Name
'Speed: ' + $cpu.MaxClockSpeed

''
#Information about Logical Drives (Includes mapped drives and I believe PSDrives)
'Storage'
Get-WMIObject -Class Win32_LogicalDisk
#$storage = Get-WMIObject -Class Win32_LogicalDisk
#'Name: ' + $storage.VolumeName
#'Drive: ' + $storage.DeviceID
#'Capacity: ' + $storage.Size
#'Available: ' + $storage.FreeSpace
#'Network Location: ' + $storage.ProviderName