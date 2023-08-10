-- =======================================================================================================
-- Author:		Tony Houlihan
-- Create date:		07Jan14
-- Ref:			77893
-- Description:		Added rPharmacyGenericBilling_Transaction 
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rPharmacyGenericBilling_Transaction') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPharmacyGenericBilling_Transaction
GO

CREATE PROCEDURE pReport_Update_rPharmacyGenericBilling_Transaction

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rPharmacyGenericBilling_Transaction'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rPCTClaimFIle


SET @TEXT = '
	INSERT INTO rPharmacyGenericBilling_Transaction  (
		[PharmacyGenericBilling_TransactionID] ,
		[EntityID_Patient],
		[Caseno],
		[Surname],
		[Forename],
		[DOB],
		[PrintedInits],
		[Printed],
		[PrintedDT],
		[TransactionCharge],
		[CreatedDT],
		[SiteID])
	
	SELECT 
		[PharmacyGenericBilling_TransactionID] ,
		[EntityID_Patient],
		[Caseno],
		[Surname],
		[Forename],
		[DOB],
		[PrintedInits],
		[Printed],
		[PrintedDT],
		[TransactionCharge],
		[CreatedDT],
		[SiteID]
		
	FROM ' + @LiveDB + '.icwsys.PharmacyGenericBilling_Transaction'

EXECUTE (@TEXT)

PRINT ''
