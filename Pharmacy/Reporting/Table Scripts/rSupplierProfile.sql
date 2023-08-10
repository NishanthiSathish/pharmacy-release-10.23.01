--29Apr16 XN  123082   Added fields ReOrderLevel, ReOrderQuantity

IF OBJECT_ID('rSupplierProfile') IS NOT NULL
	DROP TABLE rSupplierProfile
GO

CREATE TABLE rSupplierProfile(
		[WSupplierProfileID] int Primary Key NOT NULL , 
		[NSVCode] varchar (7) NULL , 
		[SupCode] varchar (5) NULL , 
		[ContractNumber] varchar (10) NULL , 
		[OuterPackSize] varchar (5) NULL , 
		[PriceLastPaid] money NULL , 
		[ContractPrice] money NULL , 
		[LeadTime] varchar (3) NULL , 
		[LastReconcilePrice] money  NULL , 
		[SuppRefNo] varchar(36)  NULL ,
		[LocationID_Site] int NOT NULL ,
		[VatRate] varchar (1)  NULL ,
		[SupplierTradeName] varchar (30) NULL,
		ReOrderLevel varchar (8) NULL ,
		ReOrderQuantity varchar (6) NULL
	)
GO

