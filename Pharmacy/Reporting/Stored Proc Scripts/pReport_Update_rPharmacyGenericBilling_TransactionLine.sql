-- =======================================================================================================
-- Author:		Tony Houlihan
-- Create date:		07Jan14
-- Ref:			77893
-- Description:		Added rPharmacyGenericBilling_TransactionLine 
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rPharmacyGenericBilling_TransactionLine') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPharmacyGenericBilling_TransactionLine
GO

CREATE PROCEDURE pReport_Update_rPharmacyGenericBilling_TransactionLine

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rPharmacyGenericBilling_TransactionLine'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rPCTClaimFIle


SET @TEXT = '
	INSERT INTO rPharmacyGenericBilling_TransactionLine  (
		
	[PharmacyGenericBilling_TransactionLineID],
	[RequestID_Dispensing],
	[PrescriptionID],
	[BasePrescriptionID],
	[NSVCode],
	[LineCost],
	[PacksIssued],
	[IssueQty],
	[BaseCost],
	[markup],
	[CreateInits],
	[CreateDT],
	[ProductDesc],
	[CostAdjust],
	[MarkupAdjust],
	[DispFee],
	[DispAdjust],
	[TaxRate],
	[TaxAdjust],
	[LineAdjust],
	[PackCost],
	[TaxAmount],
	[SiteID])
	
	SELECT 
		[PharmacyGenericBilling_TransactionLineID],
	[RequestID_Dispensing],
	[PrescriptionID],
	[BasePrescriptionID],
	[NSVCode],
	[LineCost],
	[PacksIssued],
	[IssueQty],
	[BaseCost],
	[markup],
	[CreateInits],
	[CreateDT],
	[ProductDesc],
	[CostAdjust],
	[MarkupAdjust],
	[DispFee],
	[DispAdjust],
	[TaxRate],
	[TaxAdjust],
	[LineAdjust],
	[PackCost],
	[TaxAmount],
	[SiteID]
		
	FROM ' + @LiveDB + '.icwsys.PharmacyGenericBilling_TransactionLine'

EXECUTE (@TEXT)

PRINT ''
