<#
    Fills up all available memory.
    Pulled from Luke Brennan's "Beat Up Windows" script
    https://blogs.technet.microsoft.com/lukeb/2013/01/18/windows-beatup-windows-stress-memory-and-cpus/
#>

# Warning
Write-Output "Warning: This may affect system performance."

# RAM in box
$box=get-WMIobject Win32_ComputerSystem
$Global:physMB=$box.TotalPhysicalMemory / 1024 /1024

# PerfMon counters
$Global:psPerfCPU = new-object System.Diagnostics.PerformanceCounter("Processor","% Processor Time","_Total")
$Global:psPerfMEM = new-object System.Diagnostics.PerformanceCounter("Memory","Available Mbytes")
$psPerfCPU.NextValue() | Out-Null
$psPerfMEM.NextValue() | Out-Null

# Timer
$Global:psTimer   = New-Object System.Timers.Timer
$psTimer.Interval = 1500

# Every timer interval, update the CMD shell window with RAM and CPU info.
Register-ObjectEvent -InputObject $psTimer -EventName Elapsed -Action {
[int]$ram = $physMB - $psPerfMEM.NextValue()
[int]$cpu = $psPerfCPU.NextValue()
$Host.ui.rawui.WindowTitle = "$($Host.Name) | Processor: $cpu%, Memory: $ram MB"
} | Out-Null
$psTimer.start()

# Begin test.
Write-Output "Saturating RAM..."
$a = "a" * 256MB
$growArray = @()
$growArray += $a
# leave 512Mb for the OS to survive.
$HEADROOM=512
$bigArray = @()
$ram = $physMB - $psPerfMEM.NextValue()
$MAXRAM=$physMB - $HEADROOM
$k=0
while ($ram -lt $MAXRAM) {
    $bigArray += ,@($k,$growArray)
    $k += 1
    $growArray += $a
    $ram = $physMB - $psPerfMEM.NextValue()
}
Write-Output "Done."