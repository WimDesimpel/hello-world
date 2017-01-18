[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum")
 
$sqlobjectSource = new-object ("Microsoft.SqlServer.Management.Smo.Server") "MSSQLSERVER"
write-host "Simple Powershell script to backup all user database in MS SQL Server"
 
$Databases = $sqlobjectSource.Databases
$backuppath = "D:\Backup"
foreach ($Database in $Databases)
{
 if($Database.Name -eq "Test")
 {
 write-host "........... Backup in progress for " $Database.Name " database in " $sqlobjectSource.Name
 $dbname = $Database.Name
 $dbBackup = new-object ("Microsoft.SqlServer.Management.Smo.Backup")
 $dbBackup.Action = "Database" # For full database backup, can also use "Log" or "File"
 $dbBackup.Database = $dbname
 $dbBackup.CopyOnly = "true"
 $dbBackup.Devices.Add12:09 8/05/2014Device($backuppath + "\" + $dbname + ".bak", "File")
 $dbBackup.SqlBackup($sqlobjectSource)
 }
}
write-host "........... Backup Finished for " $Database.Name " database in " $sqlobjectSource.Name
write-host "............................................................"
write-host "............................................................"
$sqlobjectDestination = new-object ("Microsoft.SqlServer.Management.Smo.Server") "MSSQLSERVER\SQL2012"
write-host "...........Restoring " $Database.Name " database in "$sqlobjectDestination.Name " Server...."
$dbRestore = new-object ("Microsoft.SqlServer.Management.Smo.Restore")
$dbRestore.Database = "Test"
$dbRestore.Devices.AddDevice($backuppath + "\" + $Database.Name + ".bak", "File")
$dbRestoreFile = new-object("Microsoft.SqlServer.Management.Smo.RelocateFile")
$dbRestoreLog = new-object("Microsoft.SqlServer.Management.Smo.RelocateFile")
$dbRestoreFile.LogicalFileName = $Database.Name
$dbRestoreFile.PhysicalFileName = $sqlobjectDestination.Information.MasterDBPath + "\" + $dbRestore.Database + "_Data.mdf"
$dbRestoreLog.LogicalFileName = $Database.Name + "_Log"
$dbRestoreLog.PhysicalFileName = $sqlobjectDestination.Information.MasterDBLogPath + "\" + $dbRestore.Database + "_Log.ldf"
$dbRestore.RelocateFiles.Add($dbRestoreFile)
$dbRestore.RelocateFiles.Add($dbRestoreLog)
$dbRestore.SqlRestore($sqlobjectDestination)
write-host "...........Restored " $Database.Name " database in "$sqlobjectDestination.Name 
