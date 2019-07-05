$size = 0

foreach ($file in (get-childitem -Path C:\Users\$env:USERNAME -Recurse -ErrorAction SilentlyContinue)) {
    $size += $file.length
}

$size = [math]::round($size/1GB,2)
"$env:USERNAME - " + $size + 'GB'
Pause