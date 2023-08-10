-- 29Apr09 TH F0052134 replaced sys with icwsys
-- 01Dec10 XN F0099137 Duplicate rows in SiteProductData table causeing PK violation in rOrder (so used distinct to filter out duplicates)

IF OBJECT_ID('pReport_Update_rOrders') IS NOT NULL
	DROP PROCEDURE pReport_Update_rOrders
GO

CREATE PROCEDURE pReport_Update_rOrders

AS

DECLARE @TEXT			VARCHAR (6400)
DECLARE @TaxInclusive 	VARCHAR (1)
DECLARE @LiveDB			VARCHAR (max)   -- @LiveDB	VARCHAR (20) XN 18Mar13 59165 db name truncated
DECLARE @Month			VARCHAR (6)

SET @TaxInclusive 	= (SELECT CONVERT(VARCHAR, TaxInclusive) FROM dbo.rTaxSwitch)
SET @LiveDB 		= (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

PRINT 'Running pReport_Update_rOrders'

IF MONTH(GETDATE()) <= 9 
	SET @Month = CONVERT(VARCHAR, YEAR(GETDATE())) + '0' + CONVERT(VARCHAR, MONTH(GETDATE()))
ELSE	
	SET @Month = CONVERT(VARCHAR, YEAR(GETDATE())) + CONVERT(VARCHAR, MONTH(GETDATE()))


DELETE FROM rOrders WHERE [Month] = @Month


SET @TEXT = '
	INSERT INTO rOrders (
	
		wOrderID, 
		[Month],
		Site, 
		NSVCode, 
		Outstanding, 
		OutstandingValueNet,
		OutstandingValueGross,
		OrderDate, 
		LocCode, 
		Supplier, 
		Status, 
		NumPrefix, 
		OrderNumber, 
		PackCostNet, 
		PackCostGross, 
		PickNo, 
		ReceivedPacks, 
		ReceivedDate, 
		OrderedPacks, 
		Urgency, 
		ToFollow, 
		INTernalSiteNo, 
		INTernalMethod, 
		SupplierType, 
		PFlag, 
		CreatedUser, 
		CustOrdNo, 
		InDispute, 
		InDisputeUser, 
		ShelfPrINTed, 
		StoresDescription, 
		ContractPrice, 
		ReOrderPacksize, 
		ContractNumber, 
		TaxCode, 
		TaxRate )
	
	SELECT DISTINCT
	
		A.wOrderID, 
		
		''' + @Month + ''' [Month], 

		C.SiteNumber Site,
		A.Code NSVCode, 
		CONVERT(FLOAT, ISNULL(A.Outstanding, ''' + '0' + ''')) Outstanding, 
	
		CASE	WHEN ' + @TaxInclusive + ' = 0
			THEN CONVERT(FLOAT, ISNULL(A.Cost, ''' +  '0' + ''')) * CONVERT(FLOAT, ISNULL(A.Outstanding, ''' + '0' + ''')) /100
			ELSE (CONVERT(FLOAT, ISNULL(A.Cost, ''' + '0' + ''')) * CONVERT(FLOAT, ISNULL(A.Outstanding, ''' + '0' + ''')) /100 ) / D.TaxRate
			END OutstandingValueNet,
	
		CASE	WHEN ' + @TaxInclusive + ' = 0
			THEN ( CONVERT(FLOAT, ISNULL(A.Cost, ''' + '0' + ''')) * CONVERT(FLOAT, ISNULL(A.Outstanding, ''' + '0' + ''')) /100 ) * D.TaxRate
			ELSE CONVERT(FLOAT, ISNULL(A.Cost, '''+ '0' + ''')) * CONVERT(FLOAT, ISNULL(A.Outstanding, ''' + '0' + ''')) /100  
			END OutstandingValueGross,

		CONVERT(DATETIME, (STUFF((STUFF(RTRIM(ISNULL(OrdDate, '''')), 3, 0, ''' + '-' + ''')) ,6,0, ''' + '-' + ''')), 105) OrderDate,	
	
		A.LocCode, 
		A.SupCode Supplier, 
		A.Status, 
		A.NumPrefix, 
		A.Num OrderNumber, 
		
		CASE	WHEN ' + @TaxInclusive + ' = 0
			THEN CONVERT(FLOAT, ISNULL(A.Cost, ''' + '0' + '''))
			ELSE CONVERT(FLOAT, ISNULL(A.Cost, ''' + '0' + ''')) / D.TaxRate
			END PackCostNet,
	
		CASE	WHEN ' + @TaxInclusive + ' = 0
			THEN CONVERT(FLOAT, ISNULL(A.Cost, ''' + '0' + ''')) * D.TaxRate
			ELSE CONVERT(FLOAT, ISNULL(A.Cost, ''' + '0' + ''')) 
			END PackCostGross,
	
		A.PickNo, 
		A.Received ReceivedPacks, 
		A.RecDate ReceivedDate,
		A.QtyOrdered OrderedPacks, 
		A.Urgency, 
		A.ToFollow, 
		A.InternalSiteNo, 
		A.InternalMethod, 
		A.SupplierType, 
		A.PFlag, 
		A.CreatedUser, 
		A.CustOrdNo, 
		A.InDispute, 
		A.InDisputeUser, 
		A.ShelfPrinted, 
	
		B.storesdescription StoresDescription,
		B.contprice ContractPrice,
		B.convfact ReOrderPacksize,
		B.contno ContractNumber,
		B.VatRate TaxCode,
		
		D.TaxRate
	
	FROM
		' + @LiveDB + '.icwsys.WOrder A
	
	LEFT JOIN ' + @LiveDB + '.icwsys.wProduct B ON A.Code = B.Siscode AND A.SiteID = B.LocationID_Site
	LEFT JOIN ' + @LiveDB + '.icwsys.Site C ON A.SiteID = C.LocationID
	LEFT JOIN rTaxRates D ON B.VATRate = D.TaxCode'

EXECUTE (@TEXT)

PRINT ''
