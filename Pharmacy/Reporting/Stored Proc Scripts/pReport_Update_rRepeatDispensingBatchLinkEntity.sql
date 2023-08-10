-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added
-- =======================================================================================================


IF OBJECT_ID('pReport_Update_rRepeatDispensingBatchLinkEntity') IS NOT NULL
	DROP PROCEDURE pReport_Update_rRepeatDispensingBatchLinkEntity
GO

CREATE PROCEDURE pReport_Update_rRepeatDispensingBatchLinkEntity

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rRepeatDispensingBatchLinkEntity'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rRepeatDispensingBatchLinkEntity


SET @TEXT = '
	INSERT INTO rRepeatDispensingBatchLinkEntity (
			[BatchID],
			[EntityID]
		)
	
	SELECT 
			[BatchID],
			[EntityID]
		
	FROM ' + @LiveDB + '.icwsys.RepeatDispensingBatchLinkEntity'

EXECUTE (@TEXT)

PRINT ''
