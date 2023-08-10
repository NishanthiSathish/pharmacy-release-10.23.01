-- 
-- Note that this table is now redundent (though will still be correctly updated )
-- You should now use rSupplier2, rCustomer, or rWardProductList instead
-- 
-- 2Jul14 XN 88506
-- 

--29Apr09 TH F0052134 replaced sys with icwsys

IF OBJECT_ID('pReport_Update_rSupplier') IS NOT NULL
	DROP PROCEDURE pReport_Update_rSupplier
GO

CREATE PROCEDURE pReport_Update_rSupplier

AS

DECLARE @TEXT	VARCHAR (2048)
DECLARE @LiveDB	VARCHAR (max)

PRINT 'Running pReport_Update_rSupplier'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rSupplier


SET @TEXT = '
	INSERT INTO rSupplier (
		wSupplierID ,
		Supplier ,
		Site ,
		ContractAddress ,
		SupAddress ,
		InvAddress ,
		ContTelNo ,
		SupTelNo ,
		InvTelNo ,
		DiscountDesc ,
		DiscountVal ,
		Method ,
		OrdMessage ,
		AvLeadTime ,
		ContFaxNo ,
		SupFaxNo ,
		InvFaxNo ,
		[Name] ,
		Ptn ,
		PSis ,
		FullName ,
		DiscountBelow ,
		DiscountAbove ,
		ICode ,
		CostCentre ,
		PrintDeliveryNote ,
		PrintPickTicket ,
		SupplierType ,
		OrderOutput ,
		ReceiveGoods ,
		TopupInterval ,
		AtcSupplied ,
		TopupDate ,
		InUse ,
		WardCode ,
		OnCost ,
		InPatientDirections ,
		AdHocDelNote ,
		SiteID ,
		MinimumOrderValue )
	
	SELECT 
		wSupplierID, 
		Code Supplier, 
		B.SiteNumber Site,
		ContractAddress, 
		SupAddress, 
		InvAddress, 
		ContTelNo, 
		SupTelNo, 
		InvTelNo, 
		DiscountDesc, 
		DiscountVal, 
		Method, 
		OrdMessage, 
		AvLeadTime, 
		ContFaxNo, 
		SupFaxNo, 
		InvFaxNo, 
		[Name], 
		Ptn, 
		PSis, 
		FullName, 
		DiscountBelow, 
		DiscountAbove, 
		ICode, 
		CostCentre, 
		PrintDeliveryNote, 
		PrintPickTicket, 
		SupplierType, 
		OrderOutput, 
		ReceiveGoods, 
		TopupInterval, 
		AtcSupplied, 
		TopupDate, 
		InUse, 
		WardCode, 
		OnCost, 
		InPatientDirections, 
		AdHocDelNote, 
		SiteID, 
		MinimumOrderValue
	
	FROM ' + @LiveDB + '.icwsys.wSupplier A
	
	INNER JOIN ' + @LiveDB + '.icwsys.Site B ON A.SiteID = B.LocationID'

EXECUTE (@TEXT)

PRINT ''
