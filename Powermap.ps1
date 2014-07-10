<#   
################################
# Author:         Dallas Moore #
# Date created:   Dec 2013     #
# Last updated:   Dec 2013     #
# Ver:            1.0          #
################################

.SYNOPSIS   
	This script performs port scans using the Winsock interface (System.Net.Sockets.TCPClient specifically)
    
.DESCRIPTION 
	This script will perform a port scan of a target machine by inititating the full TCP handshake.  This script
    takes 3 paramaters:
    
    Computername (Mandatory)
        -Valid switches for this parameter: -computername OR -server OR -host OR -h
    Port (Mandatory)
        -Valid switches for this parameter: -port OR -p
    TimeOut (Optional; default set to 1000 ms)
        -Valid switches for this parameter: -timeout OR -t 

.EXAMPLES   
	Basic usage:
    .\powermap.ps1 -h dc01 -p 3389
    .\powermap.ps1 -h 192.168.1.12 -p 22 -t 5000
    
    To specify a range of ports use the following syntax:
    .\powermap.ps1 -h dc01 -p (1..80)
    .\powermap.ps1 -h 10.10.10.10 -p (21..25 + 80..100 + 3389)

.NOTE
    Host information can be entered as either the host name (assuming DNS has been configured...) or as an IP address
#>

#Set-ExecutionPolicy bypass -scope currentuser -force

Param (
    [parameter(Mandatory = $True)]
    [Alias("server","host","h")]
    [string[]]$Computername,
    [parameter(Mandatory = $True)]
    [Alias("p")]
    $Port =@(),
    [parameter()]
    [Alias("t")]
    [Int32]$TimeOut = 1000
  )
Function powermap {
  #requires -version 3.0
  [cmdletbinding()]
  Param (
    [parameter(Mandatory = $True)]
    [Alias("server","host","h")]
    [string[]]$Computername,
    [parameter(Mandatory = $True)]
    [Alias("p")]
    $Port =@(),
    [parameter()]
    [Alias("t")]
    [Int32]$TimeOut = 1000
  )

  Process {
    ForEach ($Computer in $Computername) {
      ForEach ($p in $port) {
        Write-Verbose ("Checking port {0} on {1}" -f $p, $computer)
        $tcpClient = New-Object System.Net.Sockets.TCPClient
        $async = $tcpClient.BeginConnect($Computer,$p,$null,$null) 
        $wait = $async.AsyncWaitHandle.WaitOne($TimeOut,$false)
        If (-Not $Wait) {
          [pscustomobject]@{
            Computername = $Computername
            Port = $P
            State = 'Closed'
            Notes = 'Connection timed out'
          }
        } Else {
          Try {
            $tcpClient.EndConnect($async)
            [pscustomobject]@{
              Computername = $Computer
              Port = $P
              State = 'Open'
              Notes = $Null
            }
          } Catch {
            [pscustomobject]@{
              Computername = $Computer
              Port = $P
              State = 'Filtered'
              Notes = ("{0}" -f $_.Exception.Message)
            }                    
          }
        }
      }
    }
  }
}

powermap -Computername $Computername -Port $Port -TimeOut $Timeout
