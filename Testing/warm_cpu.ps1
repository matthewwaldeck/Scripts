<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-04-2019
    Language:   PowerShell
    Purpose:    Runs CPU at around 60% using basic math jobs.
                Honestly I'm just cold but don't want to slow down my machine.
                See stress_cpu.ps1 for the actual stress test.
    Last Edit:  07-04-2019
    Version:    v1.0.2
#>

# Warning
Write-Output "Warning: This may affect system performance."

$coreCount = (Get-WmiObject win32_processor | Select-Object -ExpandProperty NumberOfLogicalProcessors) /2
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