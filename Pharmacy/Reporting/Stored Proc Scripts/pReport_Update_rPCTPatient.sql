-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rPCTPatient') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPCTPatient
GO

CREATE PROCEDURE pReport_Update_rPCTPatient

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rPCTPatient'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rPCTPatient


SET @TEXT = '
	INSERT INTO rPCTPatient (
		[PCTPatientID],
		[EntityID],
		[HUHCNo],
		[HUHCExpiry],
		[CSC],
		[CSCExpiry],
		[PermResHokianga],
		[PHORegistered]
	)
	
	SELECT 
		[PCTPatientID],
		[EntityID],
		[HUHCNo],
		[HUHCExpiry],
		[CSC],
		[CSCExpiry],
		[PermResHokianga],
		[PHORegistered]
	
	FROM ' + @LiveDB + '.icwsys.PCTPatient'

EXECUTE (@TEXT)

PRINT ''
