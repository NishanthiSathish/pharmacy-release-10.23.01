-- 
-- Note that this table is now redundent (though will still be correctly updated )
-- You should now use rSupplier2, rCustomer, or rWardProductList instead
-- 
-- 2Jul14 XN 88506
-- 

IF OBJECT_ID('rSupplier') IS NOT NULL
	DROP TABLE rSupplier
GO

CREATE TABLE rSupplier (
	wSupplierID int NOT NULL ,
	Supplier varchar (5) NOT NULL ,
	Site int NOT NULL ,
	ContractAddress varchar (100) NULL ,
	SupAddress varchar (100) NULL ,
	InvAddress varchar (100) NULL ,
	ContTelNo varchar (14) NULL ,
	SupTelNo varchar (14) NULL ,
	InvTelNo varchar (14) NULL ,
	DiscountDesc varchar (70) NULL ,
	DiscountVal varchar (9) NULL ,
	Method varchar (1) NOT NULL ,
	OrdMessage varchar (50) NULL ,
	AvLeadTime varchar (4) NULL ,
	ContFaxNo varchar (14) NULL ,
	SupFaxNo varchar (14) NULL ,
	InvFaxNo varchar (14) NULL ,
	[Name] varchar (15) NULL ,
	Ptn varchar (1) NULL ,
	PSis varchar (1) NULL ,
	FullName varchar (35) NULL ,
	DiscountBelow varchar (4) NULL ,
	DiscountAbove varchar (4) NULL ,
	ICode varchar (8) NULL ,
	CostCentre varchar (15) NULL ,
	PrintDeliveryNote varchar (1) NULL ,
	PrintPickTicket varchar (1) NULL ,
	SupplierType varchar (1) NOT NULL ,
	OrderOutput varchar (1) NULL ,
	ReceiveGoods varchar (1) NULL ,
	TopupInterval varchar (2) NULL ,
	AtcSupplied varchar (1) NULL ,
	TopupDate varchar (8) NULL ,
	InUse bit NOT NULL ,
	WardCode varchar (5) NULL ,
	OnCost varchar (3) NULL ,
	InPatientDirections varchar (1) NULL ,
	AdHocDelNote varchar (1) NULL ,
	SiteID int NOT NULL ,
	MinimumOrderValue float NULL
	CONSTRAINT rSupplier_Unique_Site_Supplier UNIQUE  NONCLUSTERED 
	(
		Site,
		Supplier
	)
) 
GO


