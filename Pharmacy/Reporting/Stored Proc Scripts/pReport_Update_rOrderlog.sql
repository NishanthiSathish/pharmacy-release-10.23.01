-- 29Apr09 TH  F0052134 replaced sys with icwsys
-- 02Nov10 AJK F0086901 Added DateInvoiced
-- 16Aug11 TH  F0084761 Added DeliveryNoteReference

SET ANSI_NULLS ON
GO

IF OBJECT_ID('pReport_Update_rOrderlog') IS NOT NULL
	DROP PROCEDURE pReport_Update_rOrderlog
GO


CREATE PROCEDURE pReport_Update_rOrderlog

AS

Begin

DECLARE @MaxOfwOrderlogID	INT
DECLARE @LiveDB			VARCHAR(max)
DECLARE @TEXT 			VARCHAR(8000)

PRINT 'Running pReport_Update_rOrderlog'

--Get the max wOrderlogID to start from.
SET @MaxOfwOrderlogID = (SELECT MAX(wOrderlogID) FROM rOrderlog)
IF @MaxOfwOrderlogID IS NULL
	SET @MaxOfwOrderlogID =0

--Get the live database name from the rDatabase table
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

/*
NB:
There was an anomaly in v8 with regard to financial adjustments (kind A) in the Orderlog.
Effectively, if the supplier code is 'EDIT', which indicates that someone had edited the
drug prices directly, the amounts in the Orderlog will have to be divided by the pack size.
*/
SET @TEXT = '
	INSERT INTO rOrderlog (
		wOrderLogID,
		OrderNum,
		ConvFact,
		IssueUnits,
		DispId,
		Terminal,
		DateOrd,
		DateRec,
		QtyOrd,
		QtyRec,
		SupCode,
		BatchNum,
		ExpiryDate,
		InvNum,
		LinkedNum,
		ReasonCode,
		StockLvl,
		EntityID,
		DateOrdered,
		DateReceived,
		[Month],
		Site,	
		SiteID,
		NSVCode,
		LogDateTime,
		Kind,
		Cost,
		CostExTax,
		TaxCost,
		TaxCode,
		TaxRate,
		StockValue,
		DateInvoiced,
		DeliveryNoteReference)
	
	SELECT
		wOrderLogID,
		OrderNum,
		CAST(ConvFact AS FLOAT) ConvFact,
		IssueUnits,
		DispId,
		Terminal,
		DateOrd,
		DateRec,
		QtyOrd,
		QtyRec,
		SupCode,
		BatchNum,
		ExpiryDate,
		InvNum,
		LinkedNum,
		ReasonCode,
		StockLvl,
		EntityID,
		DateOrdered,
		DateReceived,
		SUBSTRING(CONVERT(VARCHAR, LogDateTime, 112), 0, 7) [Month],
		CAST(Site AS INT) Site,	
		SiteID,
		SisCode NSVCode,
		LogDateTime,
		Kind,
		Cost = 	
		   CASE WHEN Kind = ''A'' AND UPPER([SupCode]) = ''EDIT''
			THEN CAST(CONVERT(FLOAT, Cost) / CONVERT(FLOAT, ConvFact) AS MONEY)
			ELSE CAST(CONVERT(FLOAT, Cost) AS MONEY)
			END,
	
		CostExTax =
		   CASE WHEN Kind = ''A'' AND UPPER([SupCode]) = ''EDIT''
			THEN CAST(CONVERT(FLOAT, CostExVAT) / CONVERT(FLOAT, ConvFact) AS MONEY)
			ELSE CAST(CONVERT(FLOAT, CostExVAT) AS MONEY)
			END,
		
		TaxCost =			
		   CASE WHEN Kind = ''A'' AND UPPER([SupCode]) = ''EDIT''
			THEN CAST(CONVERT(FLOAT, VATCost) / CONVERT(FLOAT, ConvFact) AS MONEY)
			ELSE CAST(CAST(VATCost AS FLOAT) AS MONEY)
			END,
		
		VatCode TaxCode,
		VatRate TaxRate,
		StockValue,
		DateInvoiced =
			CASE WHEN DateInvoiced = ''30 Dec 1899''
			THEN Null
			ELSE DateInvoiced
			END,
		DeliveryNoteReference
	
	FROM
		' + @LiveDB + '.icwsys.wOrderlog
	
	WHERE wOrderlogID > ' + CONVERT(VARCHAR, @MaxOfwOrderlogID)

EXECUTE (@TEXT)

PRINT ''

End

GO
