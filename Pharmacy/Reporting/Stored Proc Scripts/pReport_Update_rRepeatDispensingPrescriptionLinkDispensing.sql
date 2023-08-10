-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rRepeatDispensingPrescriptionLinkDispensing') IS NOT NULL
	DROP PROCEDURE pReport_Update_rRepeatDispensingPrescriptionLinkDispensing
GO

CREATE PROCEDURE pReport_Update_rRepeatDispensingPrescriptionLinkDispensing

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rRepeatDispensingPrescriptionLinkDispensing'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rRepeatDispensingPrescriptionLinkDispensing


SET @TEXT = '
	INSERT INTO rRepeatDispensingPrescriptionLinkDispensing (
			[PrescriptionID],
			[DispensingID],
			[InUse],
			[Quantity],
			[RepeatDispensingPrescriptionLinkDispensingID],
			[SessionLock],
			[JVM]
		)
	
	SELECT 
			[PrescriptionID],
			[DispensingID],
			[InUse],
			[Quantity],
			[RepeatDispensingPrescriptionLinkDispensingID],
			[SessionLock],
			[JVM]
		
	FROM ' + @LiveDB + '.icwsys.RepeatDispensingPrescriptionLinkDispensing'

EXECUTE (@TEXT)

PRINT ''
