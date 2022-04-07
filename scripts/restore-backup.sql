CREATE OR ALTER PROC #restoreIcmDB @DBName SYSNAME, /* required */
@BackupFile NVARCHAR(MAX), /* data file backup location */
@BackupDBName NVARCHAR(MAX) /* DB name in backup file */
AS
BEGIN
DECLARE
@Sql NVARCHAR(MAX),
@DataPath NVARCHAR(MAX) = NULL;
BEGIN
PRINT 'Restoring database: ' + QUOTENAME(@BackupDBName) + ' to ' + QUOTENAME(@DBName);

SET @DataPath = CONCAT(CONVERT(NVARCHAR(MAX), SERVERPROPERTY('InstanceDefaultDataPath'))
, @DBName
, N'.mdf');
SET @Sql = 'RESTORE DATABASE ' + @DBName + '
FROM DISK=''' + @BackupFile + '''
WITH REPLACE, RECOVERY, MOVE ''' + @BackupDBName + '''
TO ''' + @DataPath + '''
';
PRINT ' Executing SQL: ' + @Sql;
EXECUTE sp_executesql @Sql;
END;

END;
GO

USE [master];
EXEC #restoreIcmDB @DBName = $(ICM_DB_NAME), @BackupFile = $(BACKUP), @BackupDBName = $(BACKUP_DB_NAME)
GO

USE $(ICM_DB_NAME);
EXEC sp_changedbowner 'intershop';
