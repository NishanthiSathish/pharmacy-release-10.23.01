-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	2Jul14
-- Ref:				55809
-- Description:		Added new rCustomer table this replaces rWSupplier for sypplier type W
-- =======================================================================================================
IF OBJECT_ID('rCustomer') IS NOT NULL
	DROP TABLE rCustomer
GO

CREATE TABLE rCustomer (
	[WCustomerID]           [int]               NOT NULL,
	[SiteNumber]            int                 NOT NULL ,
	[SiteID]                int                 NOT NULL,
	[CustomerCode]          [varchar](5)        NOT NULL,		
	[Description]           [varchar](15)       NOT NULL,
	[FullName]              [varchar](35)       NOT NULL,
	[Address]               [varchar](100)      NOT NULL,
	[TelephoneNo]           [varchar](14)       NOT NULL,
	[FaxNo]                 [varchar](14)       NOT NULL,
	[CostCentre]            [varchar](15)       NOT NULL,		
	PrintDeliveryNote       bit                 NOT NULL,
    PrintPickTicket         bit                 NOT NULL,        
    InPatientDirections     bit                 NULL,        
    OnCost                  [varchar](3)        NOT NULL,
    AdHocDelNote            bit                 NULL,   
	GlobalLocationNumber	varchar(13)			NOT NULL,     
    --LocationID_Ward         int                 NULL,
    [IsCustomer]            bit                 NOT NULL,
    UserField1              varchar(10)         NOT NULL,
    UserField2              varchar(10)         NOT NULL,
    UserField3              varchar(50)         NOT NULL,   -- Replaces WExtraSupplierData.ContactName1
    UserField4              varchar(50)         NOT NULL,   -- Replaces WExtraSupplierData.ContactName1
    InUse                   bit                 NOT NULL,
    [Notes]                 [varchar](1024)     NOT NULL
	CONSTRAINT rCustomer_Unique_CustomerCode_SiteNumber UNIQUE  NONCLUSTERED 
	(
		[CustomerCode],
		[SiteNumber]
	)
) 
GO


