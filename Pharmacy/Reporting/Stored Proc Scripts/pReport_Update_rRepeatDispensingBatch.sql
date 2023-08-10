-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added 
-- =======================================================================================================


IF OBJECT_ID('pReport_Update_rRepeatDispensingBatch') IS NOT NULL
	DROP PROCEDURE pReport_Update_rRepeatDispensingBatch
GO

CREATE PROCEDURE pReport_Update_rRepeatDispensingBatch

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rRepeatDispensingBatch'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rRepeatDispensingBatch


SET @TEXT = '
	INSERT INTO rRepeatDispensingBatch (
		[RepeatDispensingBatchID],
		[BatchDescription],
		[StatusID],
		[Factor],
		[RepeatDispensingBatchTemplateID],
		[StartDate],
		[StartSlot],
		[TotalSlots],
		[BagLabelsPerPatient],
		[SortByDate],
		[LocationID],
		[Breakfast],
		[Lunch],
		[Tea],
		[Night],
		[IncludeManual]
	)
	
	SELECT 
		[RepeatDispensingBatchID],
		[BatchDescription],
		[StatusID],
		[Factor],
		[RepeatDispensingBatchTemplateID],
		[StartDate],
		[StartSlot],
		[TotalSlots],
		[BagLabelsPerPatient],
		[SortByDate],
		[LocationID],
		[Breakfast],
		[Lunch],
		[Tea],
		[Night],
		[IncludeManual]
		
	FROM ' + @LiveDB + '.icwsys.RepeatDispensingBatch'

EXECUTE (@TEXT)

PRINT ''
