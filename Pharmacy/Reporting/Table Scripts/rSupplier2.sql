-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	2Jul14
-- Ref:				88506
-- Description:		Added new supplier table this replaces rSupplier for supplier type E and S
-- =======================================================================================================
IF OBJECT_ID('rSupplier2') IS NOT NULL
	DROP TABLE rSupplier2
GO

CREATE TABLE rSupplier2
(
	[WSupplier2ID]          [int]               NOT NULL,
	SiteNumber              int                 NOT NULL,
	[SiteID]                int                 NOT NULL,
	[SupCode]               [varchar](5)        NOT NULL,		
	[Description]           [varchar](15)       NOT NULL,
	[FullName]              [varchar](35)       NOT NULL,
    [ContractAddress]       [varchar](100)      NOT NULL,
    [SupAddress]            [varchar](100)      NOT NULL,
    [InvAddress]            [varchar](100)      NOT NULL,
    [ContTelNo]             [varchar](14)       NOT NULL,
    [SupTelNo]              [varchar](14)       NOT NULL,
    [InvTelNo]              [varchar](14)       NOT NULL,
    [ContFaxNo]             [varchar](14)       NOT NULL,
    [SupFaxNo]              [varchar](14)       NOT NULL,
    [InvFaxNo]              [varchar](14)       NOT NULL,
    [DiscountDesc]          [varchar](70)       NULL,
    [DiscountVal]           [varchar](9)        NULL,
    [Method]                [varchar](1)        NOT NULL,
    [OrdMessage]            [varchar](50)       NULL,
    [AvLeadTime]            [varchar](4)        NULL,
	[PrintTradeName]        bit                 NOT NULL,	
	[PrintNSVCode]          bit                 NOT NULL,	
    [DiscountBelow]         [varchar](4)        NULL,
    [DiscountAbove]         [varchar](4)        NULL,			
	[CostCentre]            [varchar](15)       NOT NULL,		
    [OrderOutput]           [varchar](1)        NULL,
    OnCost                  [varchar](3)        NOT NULL,
    [MinimumOrderValue]     [float]             NULL,
    [LeadTime]              [varchar](1)        NULL,
    [PSO]                   [bit]               NOT NULL,
    NationalSupplierCode    varchar(10)         NOT NULL,
	DUNSReference	        varchar(13)			NOT NULL,
    UserField1              varchar(10)         NOT NULL,
    UserField2              varchar(10)         NOT NULL,
    UserField3				varchar(50)         NOT NULL,   -- Replaces WExtraSupplierData.ContactName1
    UserField4				varchar(50)         NOT NULL,   -- Replaces WExtraSupplierData.ContactName1
    [LocationID_PharmacyStockholding] int       NULL,
    SiteNumber_PharmacyStockholding   int       NULL,
    InUse                   bit                 NOT NULL,
	[CurrentContractData]   [varchar](1024)     NULL,		
	[NewContractData]       [varchar](1024)     NULL,		
	[DateOfChange]          [varchar](10)       NULL,		
	[Notes]                 [varchar](1024)     NOT NULL
 	CONSTRAINT rSupplier2_Unique_SupCode_SiteNumber UNIQUE  NONCLUSTERED 
	(
		[SupCode],
		[SiteNumber]
	)
)