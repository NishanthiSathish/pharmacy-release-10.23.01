-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added 
-- =======================================================================================================


IF OBJECT_ID('pReport_Update_rRepeatDispensingSupplyPatterns') IS NOT NULL
	DROP PROCEDURE pReport_Update_rRepeatDispensingSupplyPatterns
GO

CREATE PROCEDURE pReport_Update_rRepeatDispensingSupplyPatterns

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rRepeatDispensingSupplyPatterns'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rRepeatDispensingSupplyPatterns


SET @TEXT = '
	INSERT INTO rRepeatDispensingSupplyPatterns (
		[SupplyPatternID],
		[Description],
		[Days],
		[IsDefault],
		[SplitDays],
		[Active]
		)
	
	SELECT 
		[SupplyPatternID],
		[Description],
		[Days],
		[IsDefault],
		[SplitDays],
		[Active]
		
	FROM ' + @LiveDB + '.icwsys.RepeatDispensingSupplyPatterns'

EXECUTE (@TEXT)

PRINT ''

