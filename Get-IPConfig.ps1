function Get-IPConfig ([switch]$Global)
{
    #Receiving output
    $Output = ipconfig /all
    #Removing empty lines
    $Output = $Output | Where {$_}
    #Parsing each line using regular expressions
    $Result = $(switch -regex ($Output)
    {
        #First character in line not a space - adapter name
        '^\S' {
            #If $CurrentObject not an empty, then output object from it to pipeline
            if ($CurrentObject) {Write-Output $CurrentObject}
            #Create new object and put it into $CurrentObject
            $CurrentObject = New-Object -Type PSObject
            #If line contains "adapter"...
            if ($_ -match '^(.+) adapter (.+):')
            {
                #Add adapter name and type properties
                $CurrentObject | Add-Member -type noteproperty -Name "Name" -Value $Matches[2]
                $CurrentObject | Add-Member -type noteproperty -Name "Type" -Value $Matches[1]
            }
        }
        #Property name, dots and spaces, colon, value name
        '^\s+(\S[^.]+?)[.\s]+:(?: (.+\S))?\s*$' {
            #Remove spaces from property name
            $CurrentProperty = $Matches[1] -replace ' '
            $CurrentObject | Add-Member -type noteproperty -name $CurrentProperty -Value $matches[2]
        }
        #Remaining values, not start with space, dont contain colon
        '^\s+(\S[^:]*?)\s*$' {
            #Add value to property as array
            $CurrentObject.$CurrentProperty = @($CurrentObject.$CurrentProperty, $Matches[1])
        }
    })
    #Check -Global switch
    if ($Global)
    {
        #Output only global information (first object)
        Write-Output $Result[0]
    }
    else
    {
        #Output adapter information (everything except first object)
        $Result | Select-Object -Skip 1 | Write-Output
    }
}

Get-IPConfig | Where-Object Type -EQ "Ethernet" | Sort Name | FT -AutoSize -Property Name,Type,PhysicalAddress,IPv4Address,SubnetMask,DefaultGateway
