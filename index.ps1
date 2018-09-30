# index.ps1

[int]$opts = Read-Host  -Prompt "Pick one option`n`n1 - Locate media and store`n2 - Edit existing records`n"
switch ($opts) {
    1 { $opt = 1 }
    2 { $opt = 2 }
    Default { Write-Error "Unsupported option"}
}
if ($opt -eq 1) {
    & "scripts/locate-media.ps1"
}
elseif ($opt -eq 2) {
    & "scripts/rename-media.ps1"
}