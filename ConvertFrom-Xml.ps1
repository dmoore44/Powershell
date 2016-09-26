<#
################################
# Author:         Thom Lamb    #
# Adapted by:     Dallas Moore #
# Date created:   Jun 2015     #
# Last updated:                #
# Ver:            1.0          #
################################
.SYNOPSIS   
	Converts an XML file to PSObject
    
.DESCRIPTION 
	The purpose of this script is to convert an XML document to a PSObject for
    easier manipulation of the data.

.EXAMPLE   
	<reserved>
       
.NOTE
    All credit for the conversion functions of this script goes to Thom Lamb.
    Link to original: https://consciouscipher.wordpress.com/2015/06/05/converting-xml-to-powershell-psobject/

.NOTE
    I sought out the ability to convert XML documents to PSObjects for one reason: 
    I really wanted to get the output of the CrowdResponse tool in to Splunk easier.
    The workflow goes something like this:
        1. Run CrowdResponse
        2. Convert the results XML file to PSObject
        3. Convert the PSObject to JSON
        4. Send the JSON to the Splunk HTTP Event Collector
#>

function ConvertFrom-XmlPart($xml)
{
    $hash = @{}
    $xml | Get-Member -MemberType Property |
        % {
            $name = $_.Name
            if ($_.Definition.StartsWith("string ")) {
                $hash.($Name) = $xml.$($Name)
                #$hash.($Value) = $xml.$($Name).ChildNodes
            } elseif ($_.Definition.StartsWith("System.Xml")) {
                $obj = $xml.$($Name)
                $hash.($Name) = @{}
                if ($obj.HasAttributes) {
                    $attrName = $obj.Attributes | Select-Object -First 1 | % { $_.Name }
                    if ($attrName -eq "tag") {
                        $hash.($Name) = $($obj | % { $_.tag }) -join "; "
                    } else {
                        $hash.($Name) = ConvertFrom-XmlPart $obj
                    }
                }
                if ($obj.HasChildNodes) {
                    $obj.ChildNodes | % { $hash.($Name).($_.Name) = ConvertFrom-XmlPart $($obj.$($_.Name)) }
                }
            }
        }
    return $hash
}
 
function ConvertFrom-Xml($xml) 
{
    $hash = @{}
    $hash = ConvertFrom-XmlPart($xml)
    return New-Object PSObject -Property $hash
}

[xml]$xml = Get-Content -Path C:\CrowdResponse\cr_output.xml

$converted = ConvertFrom-Xml $($xml.system)
