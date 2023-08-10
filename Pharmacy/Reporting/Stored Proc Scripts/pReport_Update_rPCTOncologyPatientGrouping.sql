-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rPCTOncologyPatientGrouping') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPCTOncologyPatientGrouping
GO

CREATE PROCEDURE pReport_Update_rPCTOncologyPatientGrouping

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rPCTOncologyPatientGrouping'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rPCTOncologyPatientGrouping


SET @TEXT = '
	INSERT INTO rPCTOncologyPatientGrouping (
		[PCTOncologyPatientGroupingID],
		[Code],
		[Description]
	)
	
	SELECT 
		[PCTOncologyPatientGroupingID],
		[Code],
		[Description]
	
	FROM ' + @LiveDB + '.icwsys.PCTOncologyPatientGrouping'

EXECUTE (@TEXT)

PRINT ''
