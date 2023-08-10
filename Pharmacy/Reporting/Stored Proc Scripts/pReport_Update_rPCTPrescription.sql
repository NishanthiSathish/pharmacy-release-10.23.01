-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rPCTPrescription') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPCTPrescription
GO

CREATE PROCEDURE pReport_Update_rPCTPrescription

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rPCTPrescription'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rPCTPrescription


SET @TEXT = '
	INSERT INTO rPCTPrescription (
		[PCTPrescriptionID],
		[RequestID_Prescription],
		[PrescriberEntityID],
		[PCTOncologyPatientGroupingID],
		[PrescriptionFormNumber],
		[SpecialAuthorityNumber],
		[SpecialistEndorserEntityID],
		[EndorsementDate],
		[FullWastage]
	)
	
	SELECT 
		[PCTPrescriptionID],
		[RequestID_Prescription],
		[PrescriberEntityID],
		[PCTOncologyPatientGroupingID],
		[PrescriptionFormNumber],
		[SpecialAuthorityNumber],
		[SpecialistEndorserEntityID],
		[EndorsementDate],
		[FullWastage]
	
	FROM ' + @LiveDB + '.icwsys.PCTPrescription'

EXECUTE (@TEXT)

PRINT ''
