IF OBJECT_ID('pReport_Update_rReconciliation_GRNI') IS NOT NULL
	DROP PROCEDURE pReport_Update_rReconciliation_GRNI
GO

CREATE PROCEDURE pReport_Update_rReconciliation_GRNI

AS

--10Jul07 JKu Debugged. tmpLastTransDate failed to dropped. Increased @TEXT2 length to 200
--29Apr09 TH F0052134 replaced sys with icwsys
--21Sep11 AJK 14980 Added check to ensure that date is valid before conversion from string
--07Nov13 JKu Applied FuzzyDate function for date conversion
--28Oct14 JKu Resolve reported issue re TFS 102331. GRNI transactons for Internal Orders now filtered out.
--24Nov16 JKu Resolve reported issue re TFS 166878. GRNI transactons for EDI orders (Internal Method 'E') now included.

DECLARE @HasTax 			VARCHAR
DECLARE @LastTransDate 		DATETIME
DECLARE @Month				VARCHAR (6)
DECLARE @TEXT				VARCHAR (8000)
DECLARE @LiveDB				VARCHAR (max)
DECLARE @TEXT2				VARCHAR (200)

PRINT 'Running pReport_Update_rReconciliation_GRNI'

SET @HasTax = (SELECT TaxInclusive FROM rTaxSwitch)

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

--10Jul07 JKu Added
IF OBJECT_ID('tmpLastTransDate') IS NOT NULL
	DROP TABLE tmpLastTransDate

SET @TEXT2 = 'SELECT MAX(LogDateTime) AS LastTransDate INTO tmpLastTransDate FROM ' + @LiveDB + '.icwsys.wTranslog'
EXECUTE (@TEXT2)

SET @LastTransDate = (SELECT LastTransDate FROM tmpLastTransDate)
DROP TABLE tmpLastTransDate

IF MONTH(@LastTransDate) < 10 
	SET @Month = CONVERT(VARCHAR, YEAR(@LastTransDate)) + '0' + CONVERT(VARCHAR, MONTH(@LastTransDate))
ELSE	
	SET @Month = CONVERT(VARCHAR, YEAR(@LastTransDate)) + CONVERT(VARCHAR, MONTH(@LastTransDate))

-- Get rid of existing month's records
DELETE FROM rReconciliation_GRNI WHERE [Month] = @Month

-- Insert current records for the month concerned.
SET @TEXT = '
INSERT INTO rReconciliation_GRNI (

	wReconcilID, 
	Site, 
	[Month], 
	Supplier, 
	SupplierName, 
	OrderNumber, 
	NSVCode, 
	StoresDescription, 
	OrderDate, 
	ReceivedDate, 
	OrderedPacks, 
	PackCost, 
	ReceivedPacks, 
	NetValue, 
	GrossValue, 
	LedCode, 
	FinanceSupplierCode, 
	TaxRate, 
	LocCode, 
	OrdDate, 
	RecDate, 
	InDispute, 
	InDisputeUser, 
	SiteID, 
	Status )

SELECT 

	A.wReconcilID,
	E.SiteNumber Site,
	' + @Month + ' [Month],
	A.SupCode Supplier, 
	C.[Name] SupplierName,
	A.Num OrderNumber, 
	A.Code NSVCode, 
	B.StoresDescription,

	--07Nov13 JKu Replaced
	--CASE WHEN LEN(OrdDate) = 8 AND ISDATE(substring(OrdDate, 3,2) + ''-'' + substring(OrdDate, 1,2) + ''-'' + substring(OrdDate, 5,4)) = 1
	--	THEN CONVERT(DATETIME, (STUFF((STUFF(RTRIM(ISNULL(OrdDate, '''')), 3, 0, ''-'')) , 6, 0, ''-'')), 105)
	--	ELSE
	--		CASE WHEN LEN(OrdDate) = 6 AND ISDATE(substring(OrdDate, 3,2) + ''-'' + substring(OrdDate, 1,2) + ''-'' + substring(OrdDate, 5,2)) = 1
	--			THEN CONVERT(DATETIME, (STUFF((STUFF(RTRIM(ISNULL(OrdDate, '''')), 3, 0, ''-'')) , 6, 0, ''-'')), 5)
	--			ELSE NULL
	--			END		
	--	END OrderDate,

	--CASE WHEN LEN(RecDate) = 8 AND ISDATE(substring(RecDate, 3,2) + ''-'' + substring(RecDate, 1,2) + ''-'' + substring(RecDate, 5,4)) = 1
	--	THEN CONVERT(DATETIME, (STUFF((STUFF(RTRIM(ISNULL(RecDate, '''')), 3, 0, ''-'')) , 6, 0, ''-'')), 105)
	--	ELSE
	--		CASE WHEN LEN(RecDate) = 6 AND ISDATE(substring(RecDate, 3,2) + ''-'' + substring(RecDate, 1,2) + ''-'' + substring(RecDate, 5,2)) = 1
	--			THEN CONVERT(DATETIME, (STUFF((STUFF(RTRIM(ISNULL(RecDate, '''')), 3, 0, ''-'')) , 6, 0, ''-'')), 5)
	--			ELSE NULL
	--			END		
	--	END ReceivedDate,

	dbo.FuzzyDate(OrdDate, default) OrderDate,
	dbo.FuzzyDate(RecDate, default) OrderDate,
	--07Nov13 JKu Replaced

	A.QtyOrdered OrderedPacks, 

	A.Cost PackCost, 
	CONVERT(FLOAT, A.Received ) ReceivedPacks, 

	CASE	WHEN ' + @HasTax + ' = 0 
		THEN CAST(((CONVERT(FLOAT, A.Cost) * CONVERT(FLOAT, A.Received)) / 100) * (CONVERT(FLOAT, QtyOrdered)/ABS(QtyOrdered)) AS MONEY)
		ELSE CAST((((CONVERT(FLOAT, A.Cost) * CONVERT(FLOAT, A.Received)) / 100) * (CONVERT(FLOAT, QtyOrdered)/ABS(QtyOrdered)) / D.TaxRate ) AS MONEY)
		END NetValue,

	CASE	WHEN ' + @HasTax + ' = 0
		THEN CAST((((CONVERT(FLOAT, A.Cost) * CONVERT(FLOAT, A.Received)) / 100) * (CONVERT(FLOAT, QtyOrdered)/ABS(QtyOrdered)) * D.TaxRate ) AS MONEY)
		ELSE CAST(((CONVERT(FLOAT, A.Cost) * CONVERT(FLOAT, A.Received)) / 100) * (CONVERT(FLOAT, QtyOrdered)/ABS(QtyOrdered)) AS MONEY)
		END GrossValue,

	B.LedCode,
	C.CostCentre FinanceSupplierCode,

	D.TaxRate,
	A.LocCode, 
	A.OrdDate, 
	A.RecDate, 
	A.InDispute, 
	A.InDisputeUser, 
	A.SiteID, 
	A.Status

FROM 	' + @LiveDB + '.icwsys.wReconcil A 

LEFT JOIN ' + @LiveDB + '.icwsys.wProduct B ON A.Code = B.SisCode AND A.SiteID = B.LocationID_Site
LEFT JOIN rSupplier C ON A.SupCode  = C.Supplier AND A.SiteID = C.SiteID
LEFT JOIN rTaxRates D ON B.VatRate = D.TaxCode
INNER JOIN ' + @LiveDB + '.icwsys.Site E ON A.SiteID = E.LocationID

--24Nov16 JKu Replaced
WHERE Status = ''' + '4' + ''' and IsNull(A.InternalMethod,'''') in ('''', ''' + 'E' + ''')
--WHERE Status = ''' + '4' + ''' and IsNUll(A.InternalMethod, '''') = '''''

EXECUTE (@TEXT)
--print (@Text)

PRINT ''
