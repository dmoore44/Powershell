<#
################################
# Author:         Dallas Moore #
# Date created:   Apr 2013     #
# Last updated:   Apr 2013     #
# Ver:            1.0          #
################################

    .SYNOPSIS
        Converts Unix Epoch time to a human readable form

    .DESCRIPTION
        Converts Unix Epoch time to a human readable form

    .EXAMPLE
        PS> .\ConvertFrom-EpochDate.ps1 
        Enter the Unix Epoch Time: 1327084231.40557

        Friday, January 20, 2012 1:30:31 PM 
#>

Function ConvertFrom-EpochDate ($epochDate) { 
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($epochDate)) 
}

$epochTime = Read-Host 'Enter the Unix Epoch Time'

ConvertFrom-EpochDate $epochTime
