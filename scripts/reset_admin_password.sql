USE $(ICM_DB_NAME);
-- reset admin password
UPDATE BASICCREDENTIALS
   SET PASSWORD = '7d50a66fe6ee08ffc9c479165c953bfcb38c9527748f2f88145cce01f776c3852060d59826b073f2'
     , DISABLEDUNTIL = NULL
     , FAILURECOUNT = NULL
     , OCA = OCA + 1
     , DISABLEDFLAG = 0
     , LASTMODIFIED = GETDATE()
 WHERE LOGIN='admin'
GO
