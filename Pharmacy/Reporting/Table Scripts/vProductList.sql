
/*
	Purpose:	Creates a View of the Products for reporting, includes the DSS, Stock, Supplier and Barcodes parts of the Product.

*/
SET ANSI_NULLS ON
GO

IF OBJECT_ID('vProductList') IS NOT NULL
	DROP view vProductList
GO
CREATE VIEW vProductList
AS

SELECT 

	a.[BNFCode], 
	a.[cyto], 
	a.[Description], 
	a.[DosesPerIssueUnit], 
	a.[DosingUnits], 
	a.[DPSForm], 
	a.[InsCode], 
	a.[LabelDescription], 
	a.[MlsPerPack], 
	a.[NSVCode], 
	a.[PrintForm], 
	a.[ReOrderPacksize], 
	a.[StoresDescription], 
	a.[TradeName], 
	a.[WarCode], 
	a.[WarCode2], 
	b.[AnnualUse], 
	b.[BatchTracking], 
	b.[Cost], 
	b.[DateLastPeriodEnd], 
	b.[DrugID], 
	b.[formulary], 
	b.[InUse], 
	b.[LastIssued], 
	b.[LastOrdered], 
	b.[LastStockTakeDate], 
	b.[LedgerCode], 
	b.[Local], 
	b.[LocationID_Site], 
	b.[LossesGains], 
	b.[OrderCycle], 
	b.[ProductStockID], 
	b.[ReOrderLevel], 
	b.[ReOrderQuantity], 
	b.[Site], 
	b.[StockLevel], 
	b.[StockTakeStatus], 
	b.[SupCode], 
	b.[UseThisPeriod], 
	c.[ContractNumber], 
	c.[ContractPrice], 
	c.[LastReconcilePrice], 
	c.[LeadTime],  
	c.[OuterPackSize], 
	c.[PriceLastPaid], 
	c.[SupplierTradeName], 
	c.[SuppRefNo], 
	c.[VatRate], 
	c.[WSupplierProfileID], 
	a.[Barcode], 
	a.[SupBarcode1], 
	a.[SupBarcode2], 
	a.[SupBarcode3], 
	a.[SupBarcode4], 
	a.[SupBarcode5],
	b.PNExclude,
	b.EyeLabel,
	b.PSOLabel,
	b.ExpiryWarnDays,				-- XN 78339 09Jan13
	a.DMandDReference,				-- XN 11Mar14
	b.LabelDescriptionInPatient,	-- XN 27Mar15 98073
	b.LabelDescriptionOutPatient,	-- XN 05May15 98073
	b.LocalDescription				-- XN 19May15 98073

from 
	rProduct a
	join rProductStock b on a.NSVCode = b.NSVCode
	join rSupplierProfile c on c.NSVCode = b.NSVCode and b.Supcode = c.supcode and b.LocationID_Site = c.LocationID_Site
