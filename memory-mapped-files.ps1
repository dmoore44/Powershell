# This is just a playground for working memory mapped files.

﻿$output = 'output2'
$text = "blah blah blah"

[System.Reflection.Assembly]::LoadWithPartialName("System.IO.MemoryMappedFiles")
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.MemoryMappedFiles.MemoryMappedFile")
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.MemoryMappedFiles.MemoryMappedViewStream")


<#[System.IO.MemoryMappedFiles.MemoryMappedFile]::CreateNew(
    [string]$output,
    [long] 50000)
#>
#secedit.exe /export /cfg $results >null

#$mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile].GetMethod("CreateOrOpen")
[System.IO.MemoryMappedFiles.MemoryMappedFile]$mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile].GetMethod('CreateNew()')
#$mmfva = [System.IO.MemoryMappedFiles.MemoryMappedViewAccessor]
[System.IO.MemoryMappedFiles.MemoryMappedViewAccessor]$mmfva = [System.IO.MemoryMappedFiles.MemoryMappedViewAccessor]::
$mmfwriter = [System.IO.MemoryMappedFiles.MemoryMappedViewStream].GetMethod('Write')

$mmfreader = [System.IO.MemoryMappedFiles.MemoryMappedViewStream].GetMethod('Read')
#$mmfreader.Invoke()
