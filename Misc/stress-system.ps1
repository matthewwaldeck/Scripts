<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-04-2019
    Purpose:    Fills up all available RAM, then holds the CPU at 100% utilization.
    Last Edit:  09-11-2020
    Version:    v1.2.2

    Note:
    Memory test pulled from Luke Brennan's "Beat Up Windows" script
    https://blogs.technet.microsoft.com/lukeb/2013/01/18/windows-beatup-windows-stress-memory-and-cpus/
#>

# Warning
Clear-Host
Write-Output "Warning: This may affect system performance."

# Fill up all available RAM
Write-Output "Saturating RAM..."
$a = "a" * 256MB
$growArray = @()
$growArray += $a
# Leave 512Mb for the OS to survive.
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

# This checks for how many threads are in the CPU, and starts that many jobs.
$coreCount = Get-WmiObject win32_processor | Select-Object -ExpandProperty NumberOfLogicalProcessors
Write-Output "Running jobs on $coreCount threads..."
# For each item in $coureCount, start a job.
foreach ($_ in 1..$coreCount){
    Start-Job -ScriptBlock{
    $result = 1
        foreach ($number in 1..2147483647){
            $result = $result * $number
        }
    }
}

Wait-Job *
Clear-Host
Receive-Job *
Remove-Job *