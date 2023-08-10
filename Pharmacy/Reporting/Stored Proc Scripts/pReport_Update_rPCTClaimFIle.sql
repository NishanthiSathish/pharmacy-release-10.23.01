-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rPCTClaimFIle') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPCTClaimFIle
GO

CREATE PROCEDURE pReport_Update_rPCTClaimFIle

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rPCTClaimFIle'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rPCTClaimFIle


SET @TEXT = '
	INSERT INTO rPCTClaimFile (
		[PCTClaimFileID],
		[DataSpecificationRelease],
		[SLANumber],
		[Generated],
		[System],
		[SystemVersion],
		[ScheduleDate],
		[ClaimDate],
		[FileID],
		[SiteID])
	
	SELECT 
		[PCTClaimFileID],
		[DataSpecificationRelease],
		[SLANumber],
		[Generated],
		[System],
		[SystemVersion],
		[ScheduleDate],
		[ClaimDate],
		[FileID],
		[SiteID]
		
	FROM ' + @LiveDB + '.icwsys.PCTClaimFile'

EXECUTE (@TEXT)

PRINT ''
