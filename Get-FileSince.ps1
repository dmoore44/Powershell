$EndDate = (Get-Date)
$StartDate=[datetime]”01/01/2016 00:00”
$TotalSpan = New-TimeSpan –Start $StartDate –End $EndDate
$DaysSpan = $TotalSpan.TotalDays
$time = (Get-Date).AddDays(-$(New-TimeSpan –Start $StartDate –End $EndDate).TotalDays)

Get-ChildItem | Where-Object {$_.LastWriteTime -ge $time}
