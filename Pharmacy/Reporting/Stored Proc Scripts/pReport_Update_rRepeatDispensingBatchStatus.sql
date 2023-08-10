-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added 
-- =======================================================================================================


IF OBJECT_ID('pReport_Update_rRepeatDispensingBatchStatus') IS NOT NULL
	DROP PROCEDURE pReport_Update_rRepeatDispensingBatchStatus
GO

CREATE PROCEDURE pReport_Update_rRepeatDispensingBatchStatus

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rRepeatDispensingBatchStatus'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rRepeatDispensingBatchStatus


SET @TEXT = '
	INSERT INTO rRepeatDispensingBatchStatus (
		[StatusID],
		[Description],
		[Code])
	
	SELECT 
		[StatusID],
		[Description],
		[Code]		
	FROM ' + @LiveDB + '.icwsys.RepeatDispensingBatchStatus'

EXECUTE (@TEXT)

PRINT ''
