function Get-ATJobs {
    $atjobs = AT.EXE | Select-Object -Skip 2 |
    ForEach-Object -Process {[regex]::replace($_.trim(),'\s{3,10}',',')} |
    ConvertFrom-Csv -delimiter ',' -Header 'id', 'day', 'time', 'commandline' |
    Select-Object -Property id, day, time, commandline
    }
