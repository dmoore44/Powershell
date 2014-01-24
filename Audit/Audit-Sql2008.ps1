<#
###################################
# Author:         Dallas Moore    #
# Date created:   Jan 2014        #
# Last updated:   Jan 2014        #
# Ver:            2.0             #
###################################

.SYNOPSIS   
	This script audits a SQL Server 2008 instance against the CIS Benchmark for SQL Server 2008
    
.DESCRIPTION 
	This is a cheap translation a of the CIS Benchmark for SQL Server 2008, but it works!
    Additionall, this script makes use of a function called invoke-sqlcmd2, which is modeled 
    after the official invoke-sqlcmd, but works without the additional tools installed.  

.EXAMPLES   
	Basic usage:
    .\Audit-SQL2008v2.ps1 -InstanceName INFOSEC-VM-2012\SEKRETSQUIRREL
    
.PARAMS
    InstanceName
        Use this parameter to specify the instance name that is being audited

.NOTE
    In order to modify the execution policy of the machine, this script should be run as an admin.
#>


PARAM (
    [Parameter(Mandatory = $true)]
    [string]$InstanceName = $(throw "Please specify an instance name.")
) 

# Resize the window and buffer so that output isn't dropped by the system
$pshost = get-host
$pswindow = $pshost.ui.rawui

$newsize = $pswindow.buffersize
$newsize.height = 3000
$newsize.width = 1000
$pswindow.buffersize = $newsize

$newsize = $pswindow.windowsize
$newsize.height = 102
$newsize.width = 240
$pswindow.windowsize = $newsize

# Set the system variable FormatEnumberationLimit to -1 so that output isn't truncated
$FormatEnumerationLimit = -1

# Get the current execution policy so that it can be restored later
$oldexecutionpol = Get-ExecutionPolicy
# Set the execution policy to unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Verify C:\temp exists; if not, create it
$pathtest = Test-Path C:\temp
if ($pathtest = $false){
    New-Item -ItemType directory -Path C:\temp
    Write-Host "Created C:\temp"
} else {
    Write-Host "C:\temp exists"
}

# Global variable declarations
$computername= $env:COMPUTERNAME 
$tempdir = "c:\temp" 
$file = "$tempdir\sql2008.audit.txt"

# Declare mail parameters so that the output can be mailed back to an email address
$MailParams = @{
  SMTPServer = 'mailhost.domain.com'
  Body = 'SQL 2008 Audit results'
  To = 'account@domain.com'
  From = 'account@domain.com'
  Subject = "SQL 2008 Audit Results for $env:computername--$(get-date -format 'MMddyy')"
  }

# Declare an output directory for the audit results
$outputdir="C:\temp\SQL2008--$env:computername--$(get-date -format 'MMddyy').txt"

Function Audit-SQL2008 {

# The Invoke-Sqlcmd2 function provides the same functionality as the official MS Invoke-Sqlcmd,
# but without the need to have any of the Powershell Management add-ons installed.  Yay.    
    function Invoke-Sqlcmd2 {
        param(
        [string]$ServerInstance,
        [string]$Database,
        [string]$Query,
        [Int32]$QueryTimeout=30
        )

        $conn=new-object System.Data.SqlClient.SQLConnection
        $conn.ConnectionString="Server={0};Database={1};Integrated Security=True" -f $ServerInstance,$Database
        $conn.Open()
        $cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn)
        $cmd.CommandTimeout=$QueryTimeout
        $ds=New-Object system.Data.DataSet
        $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
        [void]$da.fill($ds)
        $conn.Close()
        $ds.Tables[0]
        }
##############
# Declarations
##############

#$InstanceName = 'INFOSEC-VM-2012\SEKRETSQUIRREL'
$ProductVersion = Invoke-Sqlcmd2 -Query "SELECT SERVERPROPERTY('productversion')" -ServerInstance $InstanceName
$ProductEdition = Invoke-Sqlcmd2 -Query "SELECT SERVERPROPERTY('edition')" -ServerInstance $InstanceName
$CurrentTime = Invoke-Sqlcmd2 -Query "SELECT GETDATE()" -ServerInstance $InstanceName
$UserName = Invoke-Sqlcmd2 -Query "SELECT SUSER_SNAME()" -ServerInstance $InstanceName

#############################################################################################
# Information Gethering
# The following queries will retrieve about the database in accordance with the CIS Benchmark
#############################################################################################
 
#2.1 Set the Ad Hoc Distributed Queries Server Configuration Option to 0 Scored
$ahdq = Invoke-Sqlcmd2 -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'ad hoc distributed queries'" -ServerInstance $InstanceName
#2.2 Set the CLR Enabled Server Configuration Option to 0 Scored
$clresc = Invoke-Sqlcmd2 -Query " SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'clr enabled'" -ServerInstance $InstanceName
#2.3 Set the Cross DB Ownership Chaining Server Configuration Option to 0 Scored
$cdbocs = Invoke-Sqlcmd2 -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Cross db ownership chaining'" -ServerInstance $InstanceName
#2.4 Set the Database Mail XPs Server Configuration Option to 0	Scored
$dmxsc = Invoke-Sqlcmd2 -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Database Mail XPs'" -ServerInstance $InstanceName
#2.5 Set the Ole Automation Procedures Server Configuration Option to 0	Scored
$oapsc = Invoke-Sqlcmd2 -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Ole Automation Procedures';" -ServerInstance $InstanceName
#2.6 Set the Remote Access Server Configuration Option to 0 Scored
$rasc = Invoke-Sqlcmd2 -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Remote access'" -ServerInstance $InstanceName
#2.7 Set the Remote Admin Connections Server Configuration Option to 0 Scored
$racsc = Invoke-Sqlcmd2 -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Remote admin connections'" -ServerInstance $InstanceName
#2.8 Set the Scan For Startup Procs Server Configuration Option to 0 Scored
$sfspsc = Invoke-Sqlcmd2 -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Scan for startup procs'" -ServerInstance $InstanceName
#2.9 Set the SQL Mail XPs Server Configuration Option to 0 Scored
$smxsc = Invoke-Sqlcmd2 -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'SQL Mail XP'" -ServerInstance $InstanceName
#2.10 Set the Trustworthy Database Property to Off Scored
$tdbp = Invoke-Sqlcmd2 -Query "SELECT name FROM sys.databases WHERE is_trustworthy_on = 1 AND name != 'msdb' AND state = 0" -ServerInstance $InstanceName
#2.11 Disable Unnecessary SQL Server Protocols. Not Scored
$sqlservices = New-Object 'Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer'
#2.12 Configure SQL Server to use non-standard ports. Not Scored
$portsinuse = netstat.exe -ano | select-string -pattern '^(.*)\s(\d\.\d\.\d\.\d:1433)(.*)(LISTENING)(.*)$'
#2.13 Set the 'Hide Instance' option to 'Yes' for Production SQL Server instances Scored
[string]$server_name = $env:COMPUTERNAME;
[string]$instance_name = "SEKRETSQUIRREL";
[string]$key = "SOFTWARE\\Microsoft\\Microsoft SQL Server\\Instance Names\\SQL";
[PsObject]$registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $server_name);
[PsObject]$registry_key = $registry.OpenSubKey($key);
[string]$reg_instance = $registry_key.GetValue($instance_name);
$key = "SOFTWARE\\Microsoft\\Microsoft SQL Server\\$reg_instance\\MSSQLServer\\SuperSocketNetLib";
$registry_key = $registry.OpenSubKey($key);
$hideSqlInstance = $registry_key.GetValue("HideInstance");
#2.14 Disable the sa Login Account Scored
$salad = Invoke-Sqlcmd2 -Query "SELECT name, is_disabled FROM sys.server_principals WHERE sid = 0x01" -ServerInstance $InstanceName
#2.15 Rename the sa Login Account Scored
$rsala = Invoke-Sqlcmd2 -Query "SELECT name FROM sys.server_principals WHERE sid = 0x01" -ServerInstance $InstanceName
#3.1 Revoke Execute on xp_availablemedia to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure.	Scored
$rexpamp = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_availablemedia') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.2 Set the xp_cmdshell option to disabled. A run value of 0 indicates that the xp_cmdshell option is disabled. Scored
$xpcsd = Invoke-Sqlcmd2 -Query "EXECUTE sp_configure 'show advanced options',1; RECONFIGURE WITH OVERRIDE; EXECUTE sp_configure 'xp_cmdshell'" -ServerInstance $InstanceName
#3.3 Revoke Execute on xp_dirtree to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexpdtp = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_dirtree') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.4 Revoke Execute on xp_enumgroups to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexpeg = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_enumgroups') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.5 Revoke Execute on xp_fixeddrives to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexpfd = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_fixeddrives') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.6 Revoke Execute on xp_servicecontrol to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexpsc = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_servicecontrol') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.7 Revoke Execute on xp_subdirs to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexpsd = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_subdirs') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.8 Revoke Execute on xp_regaddmultistring to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexprams = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_regaddmultistring') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.9 Revoke Execute on xp_regdeletekey to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexprdk = Invoke-Sqlcmd -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_regdeletekey') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.10 Revoke Execute on xp_regdeletevalue to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure.
$rexprdv = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_regdeletevalue') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.11 Revoke Execute on xp_regenumvalues to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexprev = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_regenumvalues') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.12 Revoke Execute on xp_regremovemultistring to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure.	Scored
$rexprrms = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_regremovemultistring') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.13 Revoke Execute on xp_regwrite to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexprw = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_regwrite') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#3.14 Revoke Execute on xp_regread to PUBLIC. Any record returned indicates the public role maintains execute permission on the procedure. Scored
$rexprr = Invoke-Sqlcmd2 -Query "select (CONVERT(char(20), OBJECT_NAME(major_id))) as 'extended_procedure', (CONVERT(char(20), permission_name)) as 'permission_name', 'PUBLIC' as 'to_principal' from sys.database_permissions where major_id = OBJECT_ID('xp_regread') AND [type] = 'EX' AND grantee_principal_id = 0" -ServerInstance $InstanceName
#4.1 Set The Server Authentication Property To Windows Authentication mode. A config_value of Windows NT Authentication indicates the Server Authentication property is set to Windows Authentication mode. Scored
$sapwam = Invoke-Sqlcmd2 -Query "exec xp_loginconfig 'login mode'" -ServerInstance $InstanceName
#4.2 Revoke CONNECT permissions on the guest user within all SQL Server databases excluding the master, msdb and tempdb	Scored
$sqlscript = @"
SET NOCOUNT ON
CREATE TABLE #guest_perms 
 ( db SYSNAME, class_desc SYSNAME, 
  permission_name SYSNAME, ObjectName SYSNAME NULL)
EXEC master.sys.sp_MSforeachdb
'INSERT INTO #guest_perms
 SELECT ''?'' as DBName, p.class_desc, p.permission_name, 
   OBJECT_NAME (major_id, DB_ID(''?'')) as ObjectName
 FROM [?].sys.database_permissions p JOIN [?].sys.database_principals l
  ON p.grantee_principal_id= l.principal_id 
 WHERE l.name = ''guest'' AND p.[state] = ''G'''
 
SELECT db AS DatabaseName, class_desc, permission_name, 
 CASE WHEN class_desc = 'DATABASE' THEN db ELSE ObjectName END as ObjectName, 
 CASE WHEN DB_ID(db) IN (1, 2, 4) AND permission_name = 'CONNECT' THEN 'Default' 
  ELSE 'Potential Problem!' END as CheckStatus
FROM #guest_perms
DROP TABLE #guest_perms
"@
$rcpguinfo = Invoke-Sqlcmd2 -Query $sqlscript -ServerInstance $InstanceName
$rcpgufiltered = $rcpguinfo | Where-Object {$_.CheckStatus -notlike "Default"}
$rcpgu = $rcpgufiltered.DatabaseName
#4.3 4.3 Drop Orphaned Users From SQL Server Databases Scored
$doussd = Invoke-Sqlcmd2 -Query "EXEC sp_change_users_login @Action='Report'" -ServerInstance $InstanceName
#5.1 Set the MUST_CHANGE Option to ON for All SQL Authenticated Logins	Not Scored
$smco #No command with this variable.
#5.2 Set the CHECK_EXPIRATION Option to ON for All SQL Authenticated Logins Within the Sysadmin Role. Scored
$sceo = Invoke-Sqlcmd2 -Query "SELECT SQLLoginName = sp.name, PasswordExpirationEnforced = CAST(sl.is_expiration_checked AS BIT) FROM sys.server_principals sp JOIN sys.sql_logins AS sl ON sl.principal_id = sp.principal_id WHERE sp.type_desc = 'SQL_LOGIN'" -ServerInstance $InstanceName
#5.3 Set the CHECK_POLICY Option to ON for All SQL Authenticated Logins. Scored
$scpo = Invoke-Sqlcmd2 -Query "SELECT SQLLoginName = sp.name, PasswordPolicyEnforced = CAST(sl.is_policy_checked AS BIT) FROM sys.server_principals sp JOIN sys.sql_logins AS sl ON sl.principal_id = sp.principal_id WHERE sp.type_desc = 'SQL_LOGIN'" -ServerInstance $InstanceName
#6.1 Set the Maximum number of error log files setting to greater than or equal to 12. Not Scored
$smnelf #No command with this variable.
#6.2 Set the Default Trace Enabled Server Configuration Option to 1
$sdtes = Invoke-Sqlcmd2 -Query "SELECT name, CAST(value as int) as value_configured, CAST(value_in_use as int) as value_in_use FROM sys.configurations WHERE name = 'Default trace enabled'" -ServerInstance $InstanceName
#6.3 Set Login Auditing to Both failed and successful logins. A config_value of all indicates a server login auditing setting of Both failed and successful logins. Not Scored
$slafs = Invoke-Sqlcmd2 -Query "exec XP_loginconfig 'audit level'" -ServerInstance $InstanceName
#7.1 Sanitize Database and Application User Input. Not Scored
$sdaui #No Command
#7.2 Set the CLR Assembly Permission Set to SAFE_ACCESS for All CLR Assemblies. All the returned assemblies should show SAFE_ACCESS in the permission_set_desc column. Scored
$sclrapsa = Invoke-Sqlcmd2 -Query "SELECT name, permission_set_desc FROM sys.assemblies where is_user_defined = 1" -ServerInstance $InstanceName
#Extra
$auditsettingsscript = @"
SELECT t.EventID, t.ColumnID, e.name as Event_Description, c.name as Column_Description
   FROM ::fn_trace_geteventinfo(1) t
     JOIN sys.trace_events e ON t.eventID = e.trace_event_id
     JOIN sys.trace_columns c ON t.columnid = c.trace_column_id
"@
$auditsettingsresult = Invoke-Sqlcmd2 -Query $auditsettingsscript -ServerInstance $InstanceName




#####################
# Perform the evaluations and display the results
#####################
$hashPropsFormalities = @{
    "Instance Name" = $InstanceName
    "Product Version" = $ProductVersion[0]
    "Product Edition" = $ProductEdition[0]
    "User Name" = $UserName[0]
    "Current Time" = $CurrentTime[0]
}

$hashPropsFormalities | FT -HideTableHeaders

switch ($ahdq.value_configured -eq 0 -and $ahdq.value_in_use -eq 0) {
True {"2.1 Set the Ad Hoc Distributed Queries Server Configuration Option to 0:                                      Pass"}
False {"2.1 Set the Ad Hoc Distributed Queries Server Configuration Option to 0:                                      Deficient"}
}

switch ($clresc.value_configured -eq 0 -and $clresc.value_in_use -eq 0) {
True {"2.2 Set the CLR Enabled Server Configuration Option to 0:                                                     Pass"}
False {"2.2 Set the CLR Enabled Server Configuration Option to 0:                                                     Deficient"}
}

switch ($cdbocs.value_configured -eq 0 -and $cdbocs.value_in_use -eq 0) {
True {"2.3 Set the Cross DB Ownership Chaining Server Configuration Option to 0:                                     Pass"}
False {"2.3 Set the Cross DB Ownership Chaining Server Configuration Option to 0:                                     Deficient"}
}

switch ($dmxsc.value_configured -eq 0 -and $dmxsc.value_in_use -eq 0) {
True {"2.4 Set the Database Mail XPs Server Configuration Option to 0:                                               Pass"}
False {"2.4 Set the Database Mail XPs Server Configuration Option to 0:                                               Deficient"}
}

switch ($oapsc.value_configured -eq 0 -and $oapsc.value_in_use -eq 0) {
True {"2.5 Set the Ole Automation Procedures Server Configuration Option to 0:                                       Pass"}
False {"2.5 Set the Ole Automation Procedures Server Configuration Option to 0:                                       Deficient"}
}

switch ($rasc.value_configured -eq 0 -and $rasc.value_in_use -eq 0) {
True {"2.6 Set the Remote Access Server Configuration Option to 0:                                                   Pass"}
False {"2.6 Set the Remote Access Server Configuration Option to 0:                                                   Deficient"}
}

switch ($racsc.value_configured -eq 0 -and $racsc.value_in_use -eq 0) {
True {"2.7 Set the Remote Admin Connections Server Configuration Option to 0:                                        Pass"}
False {"2.7 Set the Remote Admin Connections Server Configuration Option to 0:                                        Deficient"}
}

switch ($sfspsc.value_configured -eq 0 -and $sfspsc.value_in_use -eq 0) {
True {"2.8 Set the Scan For Startup Procs Server Configuration Option to 0:                                          Pass"}
False {"2.8 Set the Scan For Startup Procs Server Configuration Option to 0:                                          Deficient"}
}

switch ($smxsc.value_configured -eq 0 -and $smxsc.value_in_use) {
$null {"2.9 Set the SQL Mail XPs Server Configuration Option to 0:                                                    Null; Deficient"}
True {"2.9 Set the SQL Mail XPs Server Configuration Option to 0:                                                    Pass"}
False {"2.9 Set the SQL Mail XPs Server Configuration Option to 0:                                                    Deficient"}
}

switch ($tdbp.name) {
$null {"2.10 Set the Trustworthy Database Property to Off:                                                            Pass"}
{!$null} {"2.10 Set the Trustworthy Database Property to Off:                                                            Deficient - $($tdbp.name)"}
}

switch ($sqlservices) {
$null {"2.11 Disable Unnecessary SQL Server Protocols:                                                            No Score, no protocols returned"}
{!$null} {"2.11 Disable Unnecessary SQL Server Protocols:                                                                No Score, verify protocols in use"}
}

switch ($portsinuse -eq $null) {
True {"2.12 Configure SQL Server to use non-standard ports:                                                          No Score, port 1433 not being used"}
False {"2.12 Configure SQL Server to use non-standard ports:                                                          No Score, port 1433 in use: $($portsinuse)"}
}

switch ($hideSqlInstance) {
0 {"2.13 Set the 'Hide Instance' option to 'Yes' for Production SQL Server instances:                             Deficient"}
1 {"2.13 Set the 'Hide Instance' option to 'Yes' for Production SQL Server instances:                                 Pass"}
}

switch ($salad.is_disabled) {
True {"2.14 Disable the sa Login Account:                                                                            Pass"}
False {"2.14 Disable the sa Login Account:                                                                            Deficient"}
}

switch ($rsala.name -eq "sa") {
False {"2.15 Rename the sa Login Account:                                                                            Pass"}
True {"2.15 Rename the sa Login Account:                                                                             Deficient"}
}

switch ($rexpamp -eq $null) {
True {"3.1 Revoke Execute on xp_availablemedia to PUBLIC:                                                            Pass"}
False {"3.1 Revoke Execute on xp_availablemedia to PUBLIC:                                                            Deficient"}
}

switch ($xpcsd.run_value) {
0 {"3.2 Set the xp_cmdshell option to disabled:                                                                   Pass"}
1 {"3.2 Set the xp_cmdshell option to disabled:                                                                    Deficient"}
}

switch ($rexpdtp -eq $null) {
True {"3.3 Revoke Execute on xp_dirtree to PUBLIC:                                                                   Pass"}
False {"3.3 Revoke Execute on xp_dirtree to PUBLIC:                                                                   Deficient"}
}

switch ($rexpeg -eq $null) {
True {"3.4 Revoke Execute on xp_enumgroups to PUBLIC:                                                                Pass"}
False {"3.4 Revoke Execute on xp_enumgroups to PUBLIC:                                                                Deficient"}
}

switch ($rexpfd -eq $null) {
True {"3.5 Revoke Execute on xp_fixeddrives to PUBLIC:                                                               Pass"}
False {"3.5 Revoke Execute on xp_fixeddrives to PUBLIC:                                                               Deficient"}
}

switch ($rexpsc -eq $null) {
True {"3.6 Revoke Execute on xp_servicecontrol to PUBLIC:                                                            Pass"}
False {"3.6 Revoke Execute on xp_servicecontrol to PUBLIC:                                                            Deficient"}
}

switch ($rexpsd -eq $null) {
True {"3.7 Revoke Execute on xp_subdirs to PUBLIC:                                                                   Pass"}
False {"3.7 Revoke Execute on xp_subdirs to PUBLIC:                                                                   Deficient"}
}

switch ($rexprams -eq $null) {
True {"3.8 Revoke Execute on xp_regaddmultistring to PUBLIC:                                                         Pass"}
False {"3.8 Revoke Execute on xp_regaddmultistring to PUBLIC:                                                         Deficient"}
}

switch ($rexprdk -eq $null) {
True {"3.9 Revoke Execute on xp_regdeletekey to PUBLIC:                                                              Pass"}
False {"3.9 Revoke Execute on xp_regdeletekey to PUBLIC:                                                              Deficient"}
}

switch ($rexprdv -eq $null) {
True {"3.10 Revoke Execute on xp_regdeletevalue to PUBLIC:                                                           Pass"}
False {"3.10 Revoke Execute on xp_regdeletevalue to PUBLIC:                                                           Deficient"}
}

switch ($rexprev -eq $null) {
True {"3.11 Revoke Execute on xp_regenumvalues to PUBLIC:                                                            Pass"}
False {"3.11 Revoke Execute on xp_regenumvalues to PUBLIC:                                                            Deficient"}
}

switch ($rexprrms -eq $null) {
True {"3.12 Revoke Execute on xp_regremovemultistring to PUBLIC:                                                     Pass"}
False {"3.12 Revoke Execute on xp_regremovemultistring to PUBLIC:                                                     Deficient"}
}

switch ($rexprw -eq $null) {
True {"3.13 Revoke Execute on xp_regwrite to PUBLIC:                                                                 Pass"}
False {"3.13 Revoke Execute on xp_regwrite to PUBLIC:                                                                 Deficient"}
}

switch ($rexprr -eq $null) {
True {"3.14 Revoke Execute on xp_regread to PUBLIC:                                                                  Pass"}
False {"3.14 Revoke Execute on xp_regread to PUBLIC:                                                                  Deficient"}
}

switch ($sapwam.config_value -eq "Windows NT Authentication") {
True {"4.1 Set The Server Authentication Property To Windows Authentication mode:                                    Pass"}
False {"4.1 Set The Server Authentication Property To Windows Authentication mode:                                    Deficient"}
}

switch ($rcpgu[0] -eq $null) {
True {"4.2 Revoke CONNECT perms on the guest user within all databases excluding master, msdb and tempdb:            Pass"}
False {"4.2 Revoke CONNECT perms on the guest user within all databases excluding master, msdb and tempdb:            Deficient: $($rcpgu)"}
}

switch ($doussd -eq $null) {
True {"4.3 Drop Orphaned Users From SQL Server Databases:                                                            Pass"}
False {"4.3 Drop Orphaned Users From SQL Server Databases:                                                            Deficient"}
}

switch ($smco -eq $null) {
True {"5.1 Set the MUST_CHANGE Option to ON for All SQL Authenticated Logins:                                        No Score"}
False {"5.1 Set the MUST_CHANGE Option to ON for All SQL Authenticated Logins:                                        No Score"}
}

switch ($sceo.PasswordExpirationEnforced.Contains($False)) {
True {"5.2 Set the CHECK_EXPIRATION Option to ON for All SQL Authenticated Logins Within the Sysadmin Role:          Deficient"}
False {"5.2 Set the CHECK_EXPIRATION Option to ON for All SQL Authenticated Logins Within the Sysadmin Role:          Pass"}
}

switch ($scpo.PasswordPolicyEnforced.Contains($False)) {
True {"5.3 Set the CHECK_POLICY Option to ON for All SQL Authenticated Logins:                                       Deficient"}
False {"5.3 Set the CHECK_POLICY Option to ON for All SQL Authenticated Logins:                                       Pass"}
}

switch ($smnelf -eq $null) {
True {"6.1 Set the Maximum number of error log files setting to greater than or equal to 12:                         No Score"}
False {"6.1 Set the Maximum number of error log files setting to greater than or equal to 12:                         No Score"}
}

switch ($sdtes.value_configured -eq 1 -and $sdtes.value_in_use -eq 1) {
True {"6.2 Set the 'Default Trace Enabled' Server Configuration Option to 1:                                         Pass"}
False {"6.2 Set the 'Default Trace Enabled' Server Configuration Option to 1:                                         Deficient"}
}

switch ($slafs.config_value -eq 'all') {
True {"6.3 Set Login Auditing to Both failed and successful logins:                                                  No score; configured correctly"}
False {"6.3 Set Login Auditing to Both failed and successful logins:                                                  No score; check audit configuration"}
}

switch ($sdaui -eq $null) {
True {"7.1 Sanitize Database and Application User Input:                                                             No Score"}
False {"7.1 Sanitize Database and Application User Input:                                                             No Score"}
}

switch ($sclrapsa.permission_set_desc -eq $null) {
True {"7.2 Set the CLR Assembly Permission Set to SAFE_ACCESS for All CLR Assemblies:                                Pass"}
False {switch ($sclrapsa.permission_set_desc.contains('UNSAFE_ACCESS')){ 
        True {"7.2 Set the CLR Assembly Permission Set to SAFE_ACCESS for All CLR Assemblies:                                Deficient"}
        False {"7.2 Set the CLR Assembly Permission Set to SAFE_ACCESS for All CLR Assemblies:                                Pass"}
        }
    }
}

$auditsettingsresult | FT -AutoSize

} #End of function

# Start a transcript of the console output
Start-Transcript -Path $outputdir

Audit-SQL2008

# Stops transcript of console output
Stop-Transcript

# Restore the old execution policy
Set-ExecutionPolicy $oldexecutionpol

# Mail the audit results to recipient found in mail params
"C:\temp\SQL2008--$env:computername--$(get-date -format 'MMddyy').txt" | Send-MailMessage @MailParams
