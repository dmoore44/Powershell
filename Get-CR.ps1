$OSarch = [Environment]::Is64BitOperatingSystem

If ($OSarch -eq $true){
    $ScriptURL = "https://raw.githubusercontent.com/dmoore44/Powershell/master/CR64bin.ps1"
    }
ElseIf ($OSarch -eq $false) {
    $ScriptURL = "https://raw.githubusercontent.com/dmoore44/Powershell/master/CR32bin.ps1"
}
Else {
$null
}

Invoke-Expression (New-Object Net.WebClient).DownloadString("$ScriptURL")
