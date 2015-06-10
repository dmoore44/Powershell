<#
################################
# Author:         Dallas Moore #
# Date created:   Jun 2015     #
# Last updated:   Jun 2015     #
# Ver:            1.0          #
################################
.SYNOPSIS   
	Locates the executable used to open a given file.
    
.DESCRIPTION 
	Locating the executable used to open a given file can prove troublesome.
    This script simplifies the task by using the Windows API to do the hard work.
    The user needs to provide the full path for the file they're attempting to
    trace.

.EXAMPLE   
	PS C:\Personal\dmoore\Documents\Powershell Scripts> .\Find-ExtensionAssociation.ps1

    cmdlet Find-ExtensionAssociation at command pipeline position 1
    Supply values for the following parameters:
    FullPath: c:\Windows\windowsupdate.log
    c:\Windows\windowsupdate.log will be launched by C:\Windows\system32\NOTEPAD.EXE
       
.Note
    The majority of this script is taken from this article:
    http://powershell.com/cs/blogs/tips/archive/2015/05/27/finding-executable.aspx
    All I have done is wrapped the original code in a function and allowed for user input.
#>

Function Find-ExtensionAssociation {

PARAM (
            [Parameter(Mandatory = $true)] 
            [string] $FullPath = $(throw "Please specify the full path to a file.")
            )

$Source = @"

using System;
using System.Text;
using System.Runtime.InteropServices;
public class Win32API
    {
        [DllImport("shell32.dll", EntryPoint="FindExecutable")] 

        public static extern long FindExecutableA(string lpFile, string lpDirectory, StringBuilder lpResult);

        public static string FindExecutable(string pv_strFilename)
        {
            StringBuilder objResultBuffer = new StringBuilder(1024);
            long lngResult = 0;

            lngResult = FindExecutableA(pv_strFilename, string.Empty, objResultBuffer);

            if(lngResult >= 32)
            {
                return objResultBuffer.ToString();
            }

            return string.Format("Error: ({0})", lngResult);
        }
    }

"@

Add-Type -TypeDefinition $Source -ErrorAction SilentlyContinue


$Executable = [Win32API]::FindExecutable($FullPath)
    
"$FullPath will be launched by $Executable"

}

Find-ExtensionAssociation
