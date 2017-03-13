$Earliest = (Get-Date).AddDays(-30)

Function Get-LogonFailures {

$LogFilter = @{
    LogName = 'Security'
    ID = 4625
    StartTime = $Earliest
    }

$events = Get-WinEvent -FilterHashtable $LogFilter | Select -Property *
foreach ($event in $events)
{
    $eventXML = $event | ConvertTo-XML
    $eventArray = New-Object -TypeName PSObject -Property @{

        EventID = $eventXML.Objects.Object.Property[1].'#text'
        EventTime = $eventXML.Objects.Object.Property[16].'#text'
  
        Message = $eventXML.Objects.Object.Property[0].'#text'
        Version = $eventXML.Objects.Object.Property[2].'#text'
        Qualifiers = $eventXML.Objects.Object.Property[3].'#text'
        Level = $eventXML.Objects.Object.Property[4].'#text'
        Task = $eventXML.Objects.Object.Property[5].'#text'
        Opcode = $eventXML.Objects.Object.Property[6].'#text'
        Keywords = $eventXML.Objects.Object.Property[7].'#text'
        RecordID = $eventXML.Objects.Object.Property[8].'#text'
        ProviderName = $eventXML.Objects.Object.Property[9].'#text'
        ProviderID = $eventXML.Objects.Object.Property[10].'#text'
        LogName = $eventXML.Objects.Object.Property[11].'#text'
        ProcessID = $eventXML.Objects.Object.Property[12].'#text'
        ThreadID = $eventXML.Objects.Object.Property[13].'#text'
        MachineName = $eventXML.Objects.Object.Property[14].'#text'
        UserID = $eventXML.Objects.Object.Property[15].'#text'
        ActivityID = $eventXML.Objects.Object.Property[17].'#text'
        RelatedActivityID = $eventXML.Objects.Object.Property[18].'#text'
        ContainerLog = $eventXML.Objects.Object.Property[19].'#text'
        MatchedQueryIDs = $eventXML.Objects.Object.Property[20].'#text'
        Bookmark = $eventXML.Objects.Object.Property[21].'#text'
        LevelDisplayName = $eventXML.Objects.Object.Property[22].'#text'
        OpCodeDisplayName = $eventXML.Objects.Object.Property[23].'#text'
        TaskDisplayName = $eventXML.Objects.Object.Property[24].'#text'
        KeywordDisplayNames = $eventXML.Objects.Object.Property[25].'#text'
        Properties = $eventXML.Objects.Object.Property[26].'#text'
        SubjectSecurityID = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[1]).P2
        SubjectAccountName = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[2]).P2
        SubjectAccountDomain = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[3]).P2
        SubjectLogonID = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[4]).P2
        LogonType = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[5]).P2
        FailureSecurityID = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[7]).P2
        FailureAccountName = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[8]).P2
        FailureAccountDomain = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[9]).P2
        FailureReason = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[11]).P2
        FailureStatusCode = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[12]).P2
        FailureSubStatusCode = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[13]).P2
        CallerProcessID = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[15]).P2
        CallerProcessName = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[16]).P3
        WorkstationName = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[18]).P2
        SourceNetworkAddress = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[19]).P2
        SourcePort = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[20]).P2
        LogonProcess = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[22]).P2
        AuthenticationPackage = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[23]).P2
        TransitedServices = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[24]).P2
        PackageNameNTLMOnly = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[25]).P2
        KeyLength = (($eventXML.Objects.Object.Property[0].'#text' | %{$_.Split(0x0D)} | Select-String -Pattern ":" | ForEach-Object{($_ -replace '\s+', '')}  | ConvertFrom-String -Delimiter ":")[26]).P2
        }
    $eventArray
    }
}
