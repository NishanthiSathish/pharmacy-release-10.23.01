-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	2Jul14
-- Ref:				55809
-- Description:		Added new rCustomer table this replaces rSupplier where supplier type is W
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rCustomer') IS NOT NULL
	DROP PROCEDURE pReport_Update_rCustomer
GO


CREATE PROCEDURE pReport_Update_rCustomer

AS

DECLARE @TEXT 		VARCHAR (max)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rCustomer'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rCustomer

SET @TEXT = 

	'INSERT INTO rCustomer (
	        [WCustomerID],
	        [SiteNumber],
	        [SiteID],
	        [CustomerCode],
	        [Description],
	        [FullName],
	        [Address],
	        [TelephoneNo],
	        [FaxNo],
	        [CostCentre],
	        PrintDeliveryNote,
            PrintPickTicket,
            InPatientDirections,
            OnCost,
            AdHocDelNote,        
			GlobalLocationNumber,
            [IsCustomer],
            UserField1,
            UserField2,
            UserField3,
            UserField4,
            InUse,
            [Notes]   
		)
	SELECT 	
	        c.[WCustomerID] as [WCustomerID],
	        s.SiteNumber as [SiteNumber],
	        [SiteID],
	        c.Code as [CustomerCode],
	        [Description],
	        [FullName],
	        [Address],
	        [TelephoneNo],
	        [FaxNo],
	        [CostCentre],
	        PrintDeliveryNote,
            PrintPickTicket,
            InPatientDirections,
            OnCost,
            AdHocDelNote,     
			GlobalLocationNumber,   
            [IsCustomer],
            UserField1,
            UserField2,
            UserField3,
            UserField4,
            InUse,
            ISNULL(ex.Notes, '''') as [Notes]   
	FROM ' + @LiveDB + '.icwsys.WCustomer               c
	JOIN ' + @LiveDB + '.icwsys.Site                    s  ON c.SiteID      = s.LocationID
	LEFT JOIN ' + @LiveDB + '.icwsys.WCustomerExtraData ex ON c.WCustomerID = ex.WCustomerID'
EXECUTE (@TEXT)

PRINT ''
GO


