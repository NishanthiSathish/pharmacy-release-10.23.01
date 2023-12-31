-- =======================================================================================================
-- Author:	Aidan Kent
-- Create date: 09/10/2008
-- Description:	Creates the rSiteProductData table and related indexes
-- =======================================================================================================
--12Apr10 AJK F0072782 Added PASANPCCode
--19May15 XN  98073 added new fields

IF OBJECT_ID('rSiteProductData') IS NOT NULL
	DROP TABLE rSiteProductData
GO

CREATE TABLE rSiteProductData(
	[barcode] varchar(13) NULL ,
	[siscode] varchar(7) NULL ,
	[code] varchar(8) NULL ,
	[labeldescription] varchar(56) NULL ,
	[tradename] varchar(30) NULL ,
	[printformv] varchar(5) NULL ,
	[storesdescription] varchar(56) NULL ,
	[convfact] int NULL ,
	[mlsperpack] real NULL ,
	[cyto] varchar(1) NULL ,
	[warcode] varchar(6) NULL ,
	[warcode2] varchar(6) NULL ,
	[inscode] varchar(6) NULL ,
	[DosesperIssueUnit] float NULL ,
	[DosingUnits] varchar(20) NULL ,
	[DPSForm] varchar(4) NULL ,
	[DrugID] int NOT NULL ,
	[LabelInIssueUnits] bit NULL ,
	[CanUseSpoon] bit NULL ,
	[DSSMasterSiteID] int NULL ,
	[SiteProductDataID] int PRIMARY KEY NOT NULL ,
	[BNF] varchar(13) NULL ,
	[ProductID] [int] NULL ,
	[PASANPCCode] varchar(6) NULL,
	[DMandDReference] bigint null				-- XN 19May15 Added missing item 
	)
GO

 CREATE  INDEX [IX_rSiteProductData_DrugID] ON [rSiteProductData]([DrugID]) WITH  FILLFACTOR = 90
GO

 CREATE  UNIQUE  INDEX [IX_rSiteProductData_Siscode_DSSMasterSiteID] ON [rSiteProductData]([siscode], [DSSMasterSiteID]) WITH  FILLFACTOR = 90
GO

 CREATE  INDEX [IX_rSiteProductData_ProductID] ON [rSiteProductData]([ProductID]) WITH  FILLFACTOR = 90
GO

