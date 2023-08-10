-- =======================================================================================================
-- Author:		Tony Houlihan
-- Create date:		07Jan14
-- Ref:			77893
-- Description:		Added rPharmacyGenericBilling_Transaction structure
-- =======================================================================================================

IF OBJECT_ID('rPharmacyGenericBilling_Transaction') IS NOT NULL
	DROP TABLE rPharmacyGenericBilling_Transaction 
GO

CREATE TABLE rPharmacyGenericBilling_Transaction(
	[PharmacyGenericBilling_TransactionID] [int] NOT NULL,
	[EntityID_Patient] [int] NULL,
	[Caseno] [varchar](10) NULL,
	[Surname] [varchar] (20) NULL,
	[Forename] [varchar](15) NULL,
	[DOB] [varchar](8) NULL,
	[PrintedInits] [varchar] (5) NULL,
	[Printed] [bit] NULL,
	[PrintedDT] [datetime] NULL,
	[TransactionCharge] [float] NULL,
	[CreatedDT] [datetime] NULL,
	[SiteID] [int] NULL
	) 
GO


