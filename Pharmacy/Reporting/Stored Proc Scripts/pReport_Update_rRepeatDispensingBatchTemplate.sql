-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added 
-- =======================================================================================================


IF OBJECT_ID('pReport_Update_rRepeatDispensingBatchTemplate') IS NOT NULL
	DROP PROCEDURE pReport_Update_rRepeatDispensingBatchTemplate
GO

CREATE PROCEDURE pReport_Update_rRepeatDispensingBatchTemplate

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rRepeatDispensingBatchTemplate'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rRepeatDispensingBatchTemplate


SET @TEXT = '
	INSERT INTO rRepeatDispensingBatchTemplate (
			[RepeatDispensingBatchTemplateID],
			[Description],
			[LocationID],
			[InPatient],
			[OutPatient],
			[Discharge],
			[Leave],
			[SelectPatientsByDefault],
			[BagLabels],
			[JVM],
			[JVMDefaultStartTomorrow],
			[JVMDuration],
			[JVMBreakfast],
			[JVMLunch],
			[JVMTea],
			[JVMNight],
			[JVMIncludeManual],
			[JVMSortByAdminSlot],
			[InUse])	
	SELECT 
			[RepeatDispensingBatchTemplateID],
			[Description],
			[LocationID],
			[InPatient],
			[OutPatient],
			[Discharge],
			[Leave],
			[SelectPatientsByDefault],
			[BagLabels],
			[JVM],
			[JVMDefaultStartTomorrow],
			[JVMDuration],
			[JVMBreakfast],
			[JVMLunch],
			[JVMTea],
			[JVMNight],
			[JVMIncludeManual],
			[JVMSortByAdminSlot],
			[InUse]
		
	FROM ' + @LiveDB + '.icwsys.RepeatDispensingBatchTemplate'

EXECUTE (@TEXT)

PRINT ''
