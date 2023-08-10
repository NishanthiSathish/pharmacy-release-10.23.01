-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rRepeatDispensingBatchAuditLog') IS NOT NULL
	DROP PROCEDURE pReport_Update_rRepeatDispensingBatchAuditLog
GO

CREATE PROCEDURE pReport_Update_rRepeatDispensingBatchAuditLog

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rRepeatDispensingBatchAuditLog'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rRepeatDispensingBatchAuditLog


SET @TEXT = '
	INSERT INTO rRepeatDispensingBatchAuditLog (
		[RepeatDispensingBatchAuditLogID],
		[RepeatDispensingBatchID],
		[StatusID],
		[DateChanged],
		[EntityID]
	)	
	SELECT 
		[RepeatDispensingBatchAuditLogID],
		[RepeatDispensingBatchID],
		[StatusID],
		[DateChanged],
		[EntityID]
		
	FROM ' + @LiveDB + '.icwsys.RepeatDispensingBatchAuditLog'

EXECUTE (@TEXT)

PRINT ''

