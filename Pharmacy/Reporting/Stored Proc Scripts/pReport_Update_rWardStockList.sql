-- 
-- Note that this table is now redundent (though will still be correctly updated )
-- You should now use rWardProductListLine instead
-- 
-- 2Jul14 XN 88922
-- 

-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	12May10
-- Ref:				F0077891
-- Description:		Add sp to copy WWArdStock data to report database
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rWardStockList') IS NOT NULL
	DROP PROCEDURE pReport_Update_rWardStockList
GO


CREATE PROCEDURE pReport_Update_rWardStockList

AS

DECLARE @TEXT 		VARCHAR (8000)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rWardStockList'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rWardStockList

SET @TEXT = 

	'INSERT INTO rWardStockList (
		[ScreenPosn],
		[NSVcode],
		[TitleText],
		[PrintLabel],
		[SiteName],
		[TopupLvl],
		[LastIssue],
		[PackSize],
		[LastIssueDate],
		[LocalCode],
		[SiteID],
		[Barcode],
		[DailyIssue],
		[WWardStockListID],
		[WSupplierID]
		)
	SELECT 	
		[ScreenPosn],
		[NSVcode],
		[TitleText],
		[PrintLabel],
		[SiteName],
		[TopupLvl],
		[LastIssue],
		[PackSize],
		CASE WHEN (ISNULL(LastIssueDate,'''') <> '''')
			 THEN convert(datetime, LastIssueDate, 103) 
		     END LastIssueDate,		
		[LocalCode],
		[SiteID],
		[Barcode],
		[DailyIssue],
		[WWardStockListID],
		[WSupplierID]
	FROM ' + @LiveDB + '.icwsys.WWardStockList'

EXECUTE (@TEXT)

PRINT ''
