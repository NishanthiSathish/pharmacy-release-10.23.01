-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	2Jul14
-- Ref:				88922
-- Description:		Added new rWardProductList table this replaces rSupplier where supplier type is L
-- =======================================================================================================
-- 24Feb15 XN Removed notes, and added VisibleToWard

IF OBJECT_ID('pReport_Update_rWardProductList') IS NOT NULL
	DROP PROCEDURE pReport_Update_rWardProductList
GO


CREATE PROCEDURE pReport_Update_rWardProductList

AS

DECLARE @TEXT 		VARCHAR (max)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rWardProductList'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rWardProductList

SET @TEXT = 

	'INSERT INTO rWardProductList (
	        [WWardProductListID],
	        SiteNumber,
	        [SiteID],
	        [Code],		
	        [Description],
	        [FullName],
	        PrintDeliveryNote,
            PrintPickTicket,
            WCustomerID,
            InUse,
			VisibleToWard
		)
	SELECT 	
	        [WWardProductListID],
	        s.SiteNumber as SiteNumber,
	        [SiteID],
	        [Code],		
	        [Description],
	        [FullName],
	        PrintDeliveryNote,
            PrintPickTicket,
            WCustomerID,
            InUse,
			VisibleToWard
	FROM ' + @LiveDB + '.icwsys.WWardProductList l
	JOIN ' + @LiveDB + '.icwsys.Site             s ON l.SiteID = s.LocationID'

EXECUTE (@TEXT)

PRINT ''
GO


