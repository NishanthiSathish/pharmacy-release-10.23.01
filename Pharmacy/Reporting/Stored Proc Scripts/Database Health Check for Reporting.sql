if exists (  select * from sysobjects where name = 'pDatabaseHealthCheck' and xtype = 'P' )
	BEGIN
		drop procedure [pDatabaseHealthCheck]
	END
GO
CREATE PROCEDURE pDatabaseHealthCheck
(
		@mail_profile_name	sysname
	,	@mail_recipients	varchar(max)
)
AS
BEGIN
	
	--27Apr11 AJK Created F0091203

	DECLARE @mail_body varchar(max)
	DECLARE @mail_subject varchar(max)

	
	--Check 7 -  REPORTING DB - Snapdate wTranslog check
	DECLARE @MaxSnapDate datetime
	DECLARE @MaxTransDateNum int
	DECLARE @MaxTransDateStr varchar(max)
	DECLARE @MaxTransDateStrFormatted varchar(max)
	DECLARE @MaxTransDate datetime
	DECLARE @TEXT VARCHAR (max)
	DECLARE @LiveDB VARCHAR (max)

	IF OBJECT_ID('tempDB..#MaxTransLog') IS NOT NULL
				DROP TABLE #MaxTransLog

	SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')
	print @LiveDB

	create table #MaxTransLog (MaxDate int null)

	SET @TEXT = 'INSERT INTO #MaxTransLog(MaxDate) SELECT max(date) as MaxDate from ' + @LiveDB + '.icwsys.wTranslog'
	EXECUTE (@TEXT)
	SET @MaxTransDateNum = (SELECT MaxDate FROM #MaxTransLog)
	SET @MaxSnapDate = (SELECT max(snapdate) from rfinancialsnapshot)
	SET @MaxTransDateStr = CAST ( @MaxTransDateNum AS varchar(max))   
	SET @MaxTransDateStrFormatted = substring(@MaxTransDateStr,7,2) + ' ' + DATENAME(month, DATEADD(month, cast(substring(@MaxTransDateStr,5,2) as int) - 1, CAST('2010-01-01' AS datetime))) + ' ' + substring(@MaxTransDateStr,1,4) + ' 00:00:00'
	SET @MaxTransDate = Cast (@MaxTransDateStrFormatted as datetime)

	if (@MaxSnapDate <> @MaxTransDate)
	BEGIN
		SET @mail_body = '
The last SnapDate from rfinancialsnapshot does not match the last date in the Live DB wTranslog
'
		SET @mail_subject = 'Database Health Check Alert for ' + db_name() + ' on ' + convert(varchar(128),serverproperty('ServerName'))
		exec msdb.dbo.sp_send_dbmail
			@profile_name = @mail_profile_name,
			@recipients = @mail_recipients,
			@body = @mail_body,
			@subject = @mail_subject ;
	END

	
END
GO
