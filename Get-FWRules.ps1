<#
################################
# Author:         Jaap Brasser #
# Modified:       Dallas Moore #
# Date created:   Jun 2013     #
# Last updated:   Jun 2013     #
# Ver:            1.1          #
################################

.SYNOPSIS   
	This script will dump the Windows Firewall settings
    
.DESCRIPTION 
	This script will dump the Windows Firewall rules using netsh, and proceed
    to filter the results based on the following criteria:
        1. The rule affects inbound traffic
        2. The rule is enabled
        3. The rule allows the connection
    
    The results displayed include the rule name, the remote IP, protocol, and local port

.EXAMPLE   
	.\Get-FWRules.ps1

.Example
    .\Get-FWRules | Where-Object {$_.Direction -match "In" -and $_.Enabled -match "Yes" -and $_.Action -match "Allow" -and $_.RemoteIP -match "Any"} | 
    Sort 'Rule Name' | FT -AutoSize -Wrap -Property 'Rule Name',Enabled,Direction,RemoteIP,RemotePort,Action,Profiles,Protocol

.Note
    The reason for specifying the properties parameter with the format-table cmdlet is to order the properties in a more logical sense
#>

################################
# Necessaries
################################

# Resize the window and buffer so that output isn't dropped by the system
$pshost = get-host
$pswindow = $pshost.ui.rawui

$newbuffersize = $pswindow.buffersize
$newbuffersize.height = 3000
$newbuffersize.width = 1000
$pswindow.buffersize = $newbuffersize

$newwinsize = $pswindow.windowsize
$newwinsize.height = 102
$newwinsize.width = 240
$pswindow.windowsize = $newwinsize

# Set the system variable FormatEnumberationLimit to -1 so that output isn't truncated
$FormatEnumerationLimit = -1

# Declare mail parameters so that the output can be mailed back to an email address
$MailParams = @{
  SMTPServer = 'mailhost.domain.com'
  Body = 'FW Rules'
  To = 'youraccount@yourdomain.com'
  From = 'youraccount@yourdomain.com'
  Subject = "FW Rules for $env:computername--$(get-date -format 'MMddyy')"
  }

# Declare an output directory for the audit results
$outputdir="C:\temp\hir--$env:computername--$(get-date -format 'MMddyy').txt"

################################
# The Reason We're here
################################

Function Get-FWRules {
Clear-Host
$Output = @(netsh advfirewall firewall show rule name=all dir=in type=dynamic)
$Object = New-Object -Type PSObject
$Output | Where {$_ -match '^([^:]+):\s*(\S.*)$' } | Foreach -Begin {
    $FirstRun = $true
    $HashProps = @{}
} -Process {
    if (($Matches[1] -eq 'Rule Name') -and (!($FirstRun))) {
        New-Object -TypeName PSCustomObject -Property $HashProps
        $HashProps = @{}
    } 
    $HashProps.$($Matches[1]) = $Matches[2]
    $FirstRun = $false
} -End {
    New-Object -TypeName PSCustomObject -Property $HashProps
    }
}

################################
# Makin' things happen
################################

# Start a transcript of the console output
Start-Transcript -Path $outputdir

# Call the Get-FWRules function to begine retrieval of firewall rules
Get-FWRules | Where-Object {$_.Direction -match "In" -and $_.Enabled -match "Yes" -and $_.Action -match "Allow"} | 
Sort 'Rule Name' | FT -AutoSize -Wrap -Property 'Rule Name',RemoteIP,Protocol,LocalPort

# Stop recording console output
Stop-Transcript

# Mail the audit results to recipient found in mail params
$outputdir | Send-MailMessage @MailParams
