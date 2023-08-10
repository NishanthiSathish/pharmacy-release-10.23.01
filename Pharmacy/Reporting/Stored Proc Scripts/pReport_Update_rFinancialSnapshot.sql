-- 29Apr09 TH F0052134 replaced sys with icwsys
IF OBJECT_ID('pReport_Update_rFinancialSnapshot') IS NOT NULL
	DROP PROCEDURE pReport_Update_rFinancialSnapshot
GO

CREATE PROCEDURE pReport_Update_rFinancialSnapshot

AS

DECLARE @SNAPDATE 	VARCHAR (11)
DECLARE @TAXInclusive 	VARCHAR (1)
DECLARE @CURRENT_MONTH 	VARCHAR (6)
DECLARE @TEXT		VARCHAR (2048)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rFinancialSnapshot'

--Get the LIVE database name
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

--Delete tmpSnapDate table if it exists
IF OBJECT_ID('tmpSnapDate') IS NOT NULL
	DROP TABLE tmpSnapDate

--Get the latest LogDateTime from the Live wTranslog table
SET @TEXT = 'SELECT MAX(LogDateTime) SnapDate INTO tmpSnapDate FROM ' + @LiveDB + '.icwsys.wTranslog'
EXECUTE (@TEXT)
SET @SNAPDATE = (SELECT CONVERT(VARCHAR, SnapDate, 103) FROM tmpSnapDate)
DROP TABLE tmpSnapDate

--Get the global switch to determine whether our cost field in wProduct is exclusive or inclusive of VAT
SET @TAXInclusive = (SELECT CONVERT(VARCHAR, TaxInclusive) FROM rTaxSwitch)

DELETE FROM rFinancialSnapshot WHERE CONVERT(VARCHAR, SnapDate, 103) = CONVERT(VARCHAR, @SNAPDATE, 103)

--Copy data from wTranslog in live to rFinancialSnapshot in Report database.
SET @TEXT = '
INSERT INTO rFinancialSnapshot (
	SnapDate,
	NSVCode,
	Site,
	StockLevel,
	ValueNet,
	ValueGross,
	LossesGainsValueNet,
	LossesGainsValueGross )

SELECT 
	CONVERT(DATETIME, ''' + @SNAPDATE + ''', 103) SnapDate,
	siscode NSVCode,
	B.SiteNumber Site,
	CONVERT(FLOAT, stocklvl) StockLevel,
	
	CASE 	WHEN ' + @TAXInclusive + ' = 0
		THEN CAST(((CONVERT(FLOAT, stocklvl)/convfact * CONVERT(FLOAT, Cost)) /100) AS MONEY)
		ELSE CAST((((CONVERT(FLOAT, stocklvl)/convfact * CONVERT(FLOAT, Cost)) /100) / C.TaxRate) AS MONEY)
		END ValueNet,

	CASE 	WHEN ' + @TAXInclusive + ' = 0
		THEN CAST((((CONVERT(FLOAT, stocklvl)/convfact * CONVERT(FLOAT, Cost)) /100) * C.TaxRate) AS MONEY)
		ELSE CAST(((CONVERT(FLOAT, stocklvl)/convfact * CONVERT(FLOAT, Cost)) /100) AS MONEY)
		END ValueGross,

	CASE 	WHEN ' + @TAXInclusive + ' = 0
		THEN CAST((CONVERT(FLOAT, LossesGains ) /100) AS MONEY)
		ELSE CAST(((CONVERT(FLOAT, LossesGains ) /100) / C.TaxRate) AS MONEY)
		END LossesGainsValueNet,

	CASE 	WHEN ' + @TAXInclusive + ' = 0
		THEN CAST(((CONVERT(FLOAT, LossesGains ) /100) * C.TaxRate) AS MONEY)
		ELSE CAST((CONVERT(FLOAT, LossesGains ) /100) AS MONEY)
		END LossesGainsValueGross

FROM ' + @LiveDB + '.icwsys.wProduct A

INNER JOIN ' + @LiveDB + '.icwsys.Site B ON A.LocationID_Site = B.LocationID

LEFT JOIN rTaxRates C ON A.vatrate = C.TaxCode'

EXECUTE (@TEXT)

PRINT ''
