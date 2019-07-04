<# DESCRIPTION
    Developer:  Matt Waldeck
    Date:       07-04-2019
    Language:   PowerShell
    Purpose:    Stresses CPU to about 50-60% using basic math jobs.
    Last Edit:  07-04-2019
    Version:    v1.0.0
#>

 $coreCount = (Get-WmiObject win32_processor | Select-Object -ExpandProperty NumberOfLogicalProcessors) /2

Write-Output "Warning: This may affect system performance."
Write-Output "Running on $coreCount threads..."

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