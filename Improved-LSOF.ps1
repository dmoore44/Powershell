$lsofcontainer = lsof -i | 
Select-Object -Skip 1 | 
ForEach-Object -Process {[regex]::replace($_.trim(),'\s+',' ')} | 
ConvertFrom-Csv -delimiter ' ' -Header 'command', 'pid', 'user', 'fd', 'type', 'device', 'size_off', 'node', 'name' | 
Select-Object -Property command, pid, user, fd, type, device, size_off, node, name, 
        @{name = 'process_name'; expression = {(Get-Process -id $_.pid).name}},
        @{name = 'session_id'; expression = {(Get-Process -id $_.pid).sessionid}},
        @{name = 'module_paths'; expression = {(Get-Process -id $_.pid).Modules.FileName -join ','}}
