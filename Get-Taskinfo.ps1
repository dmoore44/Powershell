<#
################################
# Author:         Dallas Moore #
# Date created:   Jan 2014     #
# Last updated:   Jan 2014     #
# Ver:            1.0          #
################################

.SYNOPSIS   
	Takes output from tasklist.exe and transforms it in to a Powershell object
    
.DESCRIPTION 
	The purpose of this script is to take the output from tasklist.exe and transform it in to
    a Powershell object for easy manipulation.  Upon execution, this script will present the user
    with four options:

    1 = Get module information based on an executable or DLL
    2 = Get module information for all executables
    3 = Get current task information
    4 = Get module information based on services

    * Option 1 requires the user to provide the name of a DLL and the script will return executables
      which use it as well as the PID of the executables.
    * Option 2 will provide a list of running executables, their PIDs, and the DLLs that those executables have 
      loaded.
    * Option 3 will provide verbose tasklist output to include Image Name, PID, Session Name, Session Number
      Memory Usage, Status, User Name, CPU Time, and Window Title.  Output is sorted by PID.
    * Option 4 lists all the service information for each process without truncation.


.EXAMPLE   
	.\Get-Taskinfo.ps1    

.Note
    <reserved>
#>

    Clear-Host
    Clear-History

    Function Get-Modinfo {
        
        PARAM (
            [Parameter(Mandatory = $true)] 
            [string] $modname = $(throw "Please specify an executable or dll name.")
            )

        $header2 = 'ImageName','PID','Modules'
        $modules = tasklist.exe /m "$modname" /FO CSV | Select-Object -Skip 1 | ConvertFrom-Csv -Header $header2

        $modules | FT -AutoSize
    }

    Function Get-Allmodinfo {

        $header2 = 'ImageName','PID','Modules'
        $modules = tasklist.exe /m /FO CSV | Select-Object -Skip 1 | ConvertFrom-Csv -Header $header2

        $modules | Where-Object {$_.Modules -ne "N/A"} | FT -Wrap -AutoSize
    }

    Function Get-Taskinfo {

        $header1 = 'ImageName','PID','SessionName','SessionNumber','MemUsage','Status','UserName','CPUtime', 'WindowTitle'
        $info = tasklist.exe /v /FO CSV | Select-Object -Skip 1 | ConvertFrom-Csv -Header $header1

        $info | FT -AutoSize
    }

    Function Get-Svcinfo {

        $header3 = 'ImageName','PID','Services'
        $services = tasklist.exe /svc /FO CSV | Select-Object -Skip 1 | ConvertFrom-Csv -Header $header3

        $services | FT -AutoSize
    }

Do {
    Write-Host "
    ----------Main----------
    1 = Get module information based on an executable or DLL
    2 = Get module information for all executables
    3 = Get current task information
    4 = Get module information based on services
    --------------------------"
    $choice1 = read-host -prompt "Select number & press enter"
    } until ($choice1 -eq "1" -or $choice1 -eq "2" -or $choice1 -eq "3" -or $choice1 -eq "4")

Switch ($choice1) {
"1" {Get-Modinfo}
"2" {Get-Allmodinfo}
"3" {Get-Taskinfo}
"4" {Get-Svcinfo}
}
