<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-04-2019
    Purpose:    Pins CPU to 100% using basic math jobs. Useful for testing system stability or cooling.
    Last Edit:  09-10-2020
    Version:    v1.1.3
#>

# Warning
Clear-Host
Write-Output "Warning: This may affect system performance."

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