"
$ContentToExe = [System.Convert]::FromBase64String($CR64)
Set-Content -Path $env:temp\CrowdResponse64.exe -Value $ContentToExe -Encoding Byte