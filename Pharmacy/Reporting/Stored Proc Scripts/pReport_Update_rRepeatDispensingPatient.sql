-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added
-- =======================================================================================================


IF OBJECT_ID('pReport_Update_rRepeatDispensingPatient') IS NOT NULL
	DROP PROCEDURE pReport_Update_rRepeatDispensingPatient
GO

CREATE PROCEDURE pReport_Update_rRepeatDispensingPatient

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rRepeatDispensingPatient'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rRepeatDispensingPatient


SET @TEXT = '
	INSERT INTO rRepeatDispensingPatient (
		[RepeatDispensingPatientID],
		[EntityID],
		[SupplyDays],
		[ADM],
		[InUse],
		[SupplyPatternID],
		[AdditionalInformation],
		[RepeatDispensingBatchTemplateID]
		)
	
	SELECT 
		[RepeatDispensingPatientID],
		[EntityID],
		[SupplyDays],
		[ADM],
		[InUse],
		[SupplyPatternID],
		[AdditionalInformation],
		[RepeatDispensingBatchTemplateID]
		
	FROM ' + @LiveDB + '.icwsys.RepeatDispensingPatient'

EXECUTE (@TEXT)

PRINT ''
