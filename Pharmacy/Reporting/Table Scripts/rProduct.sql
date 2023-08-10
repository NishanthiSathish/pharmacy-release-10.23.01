

-- =======================================================================================================
-- Author:			Paul Crawford (PJC)
-- Amended date:	20Aug09
-- Ref:				F0050136
-- Description:		Alters the LedgerCode field in the rProduct in the reporting database 
--					from 7 to 20 characters.
--
-- Author:			Paul Crawford (PJC)
-- Amended date:	15Oct09
-- Ref:				F0066390
-- Description:		Added Catalogue description to hold the BNF chapter/section description, added reportgroup
-- =======================================================================================================


-- =======================================================================================================
-- =======================================================================================================
-- This table should not be used for anything that is not in siteproductdata, as it does not include a SiteId field.
-- It is only kept how it is so that it does not break some site reports
-- for other WProduct fields use ProductStock, and WSupplierProfile
-- =======================================================================================================
-- =======================================================================================================


IF OBJECT_ID('rProduct') IS NOT NULL
	DROP TABLE rProduct
GO

CREATE TABLE rProduct (
	NSVCode varchar (7) PRIMARY KEY NOT NULL ,
	LabelDescription varchar (56) NULL ,
	TradeName varchar (30) NULL ,
	PrintForm varchar (5) NULL ,
	StoresDescription varchar (56) NULL ,
	ReOrderPacksize int NULL ,
	MlsPerPack real NULL ,
	cyto varchar (1) NULL ,
	WarCode varchar (6) NULL ,
	WarCode2 varchar (6) NULL ,
	InsCode varchar (6) NULL ,
	DosesPerIssueUnit float NULL ,
	DosingUnits varchar (20) NULL ,
	DPSForm varchar (4) NULL ,
	[Description] varchar (56) NULL ,
	Formulary varchar (1) NULL ,
	LabelFormat varchar (1) NULL ,
	MinUse varchar (4) NULL ,
	MaxUse varchar (5) NULL ,
	LastIssued varchar (8) NULL ,
	IssueWholePack varchar (1) NULL ,
	LiveStockCtrl varchar (1) NULL ,
	SupCode varchar (5) NULL ,
	AltSupCode varchar (29) NULL ,
	LedgerCode varchar (20) NULL ,
	StoresPack varchar (5) NULL ,
	BNFCode varchar (13) NULL ,
	TherapheuticCode varchar (2) NULL ,
	ContractPrice varchar (9) NULL ,
	ContractNumber varchar (10) NULL ,
	OuterPacksize varchar (5) NULL ,
	ReOrderLevel varchar (8) NULL ,
	ReOrderQuantity varchar (6) NULL ,
	Barcode varchar (13) NULL,
	SupBarcode1 varchar (13) NULL,
	SupBarcode2 varchar (13) NULL,
	SupBarcode3 varchar (13) NULL,
	SupBarcode4 varchar (13) NULL,
	SupBarcode5 varchar (13) NULL,
	CatalogueDescription varchar (512) NULL, 
	ReportGroup varchar(255) NULL,
	[DMandDReference] bigint null				-- XN 19May15 Added missing item 
) 
GO


