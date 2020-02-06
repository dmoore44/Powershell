<#
################################
# Author:         Dallas Moore #
# Date created:   Feb 2020     #
# Last updated:   Feb 2020     #
# Ver:            1.0          #
################################
    .SYNOPSIS
        Compresses and B64 encodes a file, or rehydrate the B64 string back to a file.
    .DESCRIPTION
        This script will compress and B64 encode a file (and/or) rehydrate the B64 string 
	back to a file for easy portability. Unthreatening looking strings tend to not get 
	stomped.
    .EXAMPLE
        I dropped the script text in to my $PSProfile ($Profile.CurrentUserAllHosts) for easy
	use. I suppose you could always dot-source it whenever you want to use it, but you do you.
	
	Then, you just do something like this:
	PS > Compress-File -File ~\Desktop\whatever.txt -outputLoc ~\Desktop\gibberish.txt
	
	PS > Decompress-File -memstream $(Get-Content -Path ~\Desktop\encoded.txt) -outputloc ~\Desktop\decoded.txt
	NOTE: In the above example, you only need to include the B64 string in your input file - if you try and run the
	Decompress-File function on the output from Compress-File, it'll fail.
	PS > Decompress-File -memstream "b64 string here" -outputLoc ~\Desktop\decoded.txt
#>

Function Compress-File {
    Param(
        [Parameter(Mandatory=$True,Position=0)]
        [String]$File,
        [Parameter(Mandatory=$True,Position=1)]
        [String]$outputLoc
    )

    Function Get-Base64GzippedStream {
    Param(
        [Parameter(Mandatory=$True,Position=0)]
        [System.IO.FileInfo]$File
    )
        # Read profile into memory stream
        $memFile = New-Object System.IO.MemoryStream (,[System.IO.File]::ReadAllBytes($File))
        
        # Create an empty memory stream to store our GZipped bytes in
        $memStrm = New-Object System.IO.MemoryStream

        # Create a GZipStream with $memStrm as its underlying storage
        $gzStrm  = New-Object System.IO.Compression.GZipStream $memStrm, ([System.IO.Compression.CompressionMode]::Compress)

        # Pass $memFile's bytes through the GZipstream into the $memStrm
        $gzStrm.Write($memFile.ToArray(), 0, $File.Length)
        $gzStrm.Close()
        $gzStrm.Dispose()

        # Return Base64 Encoded GZipped stream
        [System.Convert]::ToBase64String($memStrm.ToArray())   
    }

    $obj = "" | Select-Object FullName,Length,CreationTimeUtc,LastAccessTimeUtc,LastWriteTimeUtc,Hash,Content

    if (Test-Path($File)) {
        $Target = ls $File
        $obj.FullName          = $Target.FullName
        $obj.Length            = $Target.Length
        $obj.CreationTimeUtc   = $Target.CreationTimeUtc
        $obj.LastAccessTimeUtc = $Target.LastAccessTimeUtc
        $obj.LastWriteTimeUtc  = $Target.LastWriteTimeUtc
        $EAP = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
        Try {
            $obj.Hash              = $(Get-FileHash $File -Algorithm SHA256).Hash
        } Catch {
            $obj.Hash = 'Error hashing file'
        }
        $ErrorActionPreference = $EAP
        $obj.Content           = Get-Base64GzippedStream($Target)
    }  
    $obj | Out-File -FilePath $outputLoc 
}


Function Decompress-File {
    [CmdletBinding()] 
    
    Param ([Parameter(Mandatory)] [string[]] $memstream = $(Throw("-memstream is required")),
           [Parameter(Mandatory)] [string[]] $outputloc = $(Throw("-outputloc is required"))
    )

    function Get-DecompressedByteArray {

	    [CmdletBinding()] Param ([Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
            [byte[]] $byteArray)

	    Process {
	        Write-Verbose "Get-DecompressedByteArray"
            $input = New-Object System.IO.MemoryStream( , $byteArray )
	        $output = New-Object System.IO.MemoryStream
            $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)
	        $gzipStream.CopyTo( $output )
            $gzipStream.Close()
		    $input.Close()
		    [byte[]] $byteOutArray = $output.ToArray()
            Write-Output $byteOutArray
        }
    }


    function Write-StreamToDisk {
    
        [io.file]::WriteAllBytes("$outputloc",$(Get-DecompressedByteArray -byteArray $([System.Convert]::FromBase64String($memstream))))

    }

    Write-StreamToDisk -memstream $memstream -outputloc $outputloc
}
