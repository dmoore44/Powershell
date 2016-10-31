$dummy = Invoke-WebRequest -uri eth0.me
$ipgeo = Invoke-WebRequest -uri "ipinfo.io/$dummy.Content"
$ipgeo | ConvertFrom-Json
