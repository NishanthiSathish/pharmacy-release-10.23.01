-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	2Jul14
-- Ref:				88506
-- Description:		Added new supplier table this replaces rSupplier for supplier type E and S
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rSupplier2') IS NOT NULL
	DROP PROCEDURE pReport_Update_rSupplier2
GO


CREATE PROCEDURE pReport_Update_rSupplier2

AS

DECLARE @TEXT 		VARCHAR (max)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rSupplier2'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rSupplier2

SET @TEXT = 

	'INSERT INTO rSupplier2 (
	        [WSupplier2ID],
	        SiteNumber,
	        [SiteID],
	        [SupCode],		
	        [Description],
	        [FullName],
            [ContractAddress],
            [SupAddress],
            [InvAddress],
            [ContTelNo],
            [SupTelNo],
            [InvTelNo],
            [ContFaxNo],
            [SupFaxNo],
            [InvFaxNo],
            [DiscountDesc],
            [DiscountVal],
            [Method],
            [OrdMessage],
            [AvLeadTime],
	        [PrintTradeName],	
	        [PrintNSVCode],	
            [DiscountBelow],
            [DiscountAbove],			
	        [CostCentre],		
            [OrderOutput],
            OnCost,
            [MinimumOrderValue],
            [LeadTime],
            [PSO],
            NationalSupplierCode,
			DUNSReference,
            UserField1,
            UserField2,
            UserField3,
            UserField4,
            [LocationID_PharmacyStockholding],
            SiteNumber_PharmacyStockholding,
            InUse,
            [CurrentContractData],		
            [NewContractData],		
            [DateOfChange],		
            [Notes]            
		)
	SELECT 	
	        sup.[WSupplier2ID],
	        s.SiteNumber as SiteNumber,
	        [SiteID],
	        sup.Code     as [SupCode],		
	        [Description],
	        [FullName],
            [ContractAddress],
            [SupAddress],
            [InvAddress],
            [ContTelNo],
            [SupTelNo],
            [InvTelNo],
            [ContFaxNo],
            [SupFaxNo],
            [InvFaxNo],
            [DiscountDesc],
            [DiscountVal],
            [Method],
            [OrdMessage],
            [AvLeadTime],
	        [PrintTradeName],	
	        [PrintNSVCode],	
            [DiscountBelow],
            [DiscountAbove],			
	        [CostCentre],		
            [OrderOutput],
            OnCost,
            [MinimumOrderValue],
            [LeadTime],
            [PSO],
            NationalSupplierCode,
			DUNSReference,
            UserField1,
            UserField2,
            UserField3,
            UserField4,
            [LocationID_PharmacyStockholding],
            sh.SiteNumber as SiteNumber_PharmacyStockholding,
            InUse,
            ISNULL(ex.CurrentContractData,  '''') as [CurrentContractData],		
            ISNULL(ex.NewContractData,      '''') as [NewContractData],		
            ISNULL(ex.DateOfChange,         '''') as [DateOfChange],		
            ISNULL(ex.Notes,                '''') as [Notes]
	FROM ' + @LiveDB + '.icwsys.WSupplier2                  sup
	JOIN ' + @LiveDB + '.icwsys.[Site]                      s   on sup.SiteID                          = s.LocationID
	LEFT JOIN ' + @LiveDB + '.icwsys.[Site]                 sh  on sup.LocationID_PharmacyStockholding = sh.LocationID
	LEFT JOIN ' + @LiveDB + '.icwsys.WSupplier2ExtraData    ex  on sup.WSupplier2ID                    = ex.WSupplier2ID'

EXECUTE (@TEXT)

PRINT ''
GO
