[cmdletbinding()]
$OutputFolder="C:\Temp\Web Scrape\"
$MaxDepth=5
$Global:CheckedPages=@()
function Get-WebSubPage
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        $BaseURL,
        [Parameter(Mandatory=$true)]
        $SubLink,
        [Parameter(Mandatory=$true)]
        $CurrentDepth
    )
    $Result=@()
    $Filter="$SubLink*"
    $Page=$BaseURL+$SubLink
    Write-Verbose "Current Page: $Page Result Number: $($CheckedPages.Count) Depth: $CurrentDepth"
    $Web=Invoke-WebRequest $Page
    $OutFile=$OutputFolder + ($SubLink -replace ("[\.\:]","") -replace "//","" -Replace "/","\") + ".html"
    $OutFile=$OutFile -replace "\\.html",".html" -replace "\\\\","\"
    Write-Verbose "Output to: $OutFile"
    if (Test-Path $OutFile -IsValid)
    {
        New-Item $OutFile -Force -ItemType File > $null
        $Web.Content | Out-File $OutFile -Force
    }
    $AllLinks=$Web.links.href
    $Web=$OutFile=$Null
    if ($CurrentDepth -lt $MaxDepth)
    {
 
        Foreach ($Link in $AllLinks)
        {
            If ($Link -like $Filter)
            {
                $FullLink=$Base+$Link
                If (!($CheckedPages -contains $FullLink))
                {
                    Get-WebSubPage -BaseURL:$BaseURL -SubLink:$Link -CurrentDepth:($CurrentDepth+1)           
                }
            }
        }
    }else
    {
        Write-Verbose "Depth Reached Maximum:  Not processing links."
    }
    $Global:CheckedPages+=$Page
}
 
Get-WebSubPage -BaseURL:"https://www.ifixit.com/" -SubLink:"/" -CurrentDepth:1 -Verbose
Pause