$netstats = NETSTAT.EXE -anop tcp | Select-Object -Skip  4 |
ForEach-Object -Process {[regex]::replace($_.trim(),'\s+',' ')} |
ConvertFrom-Csv -delimiter ' ' -Header 'proto', 'src', 'dst', 'state', 'pid' |
Select-Object -Property pid, proto, dst, src, state, 
    @{name = 'process_name'; expression = {(Get-Process -id $_.pid).name}},
    @{name = 'command_line'; expression = {(gwmi win32_process -Filter "processid='$($_.pid)'").commandline}},
    @{name = 'session_id'; expression = {(Get-Process -id $_.pid).sessionid}},
    @{name = 'window_title'; expression = {(Get-Process -id $_.pid).mainwindowtitle}},
    @{name = 'ppid'; expression = {(gwmi win32_process -Filter "processid='$($_.pid)'").parentprocessid}},
    @{name = 'loaded_modules'; expression = {(Get-Process -id $_.pid).Modules.ModuleName -join ','}},
    @{name = 'module_paths'; expression = {(Get-Process -id $_.pid).Modules.FileName -join ','}}

$netstats | 
    foreach-object {
        $_ | Add-Member -MemberType NoteProperty -Name gpid -Value $((gwmi win32_process -Filter "processid='$($_.ppid)'").parentprocessid)
        $_ | Add-Member -MemberType NoteProperty -Name grandparent_process_name -Value $((gwmi win32_process -Filter "processid='$($_.ppid)'").name)
    }


$netstats 
