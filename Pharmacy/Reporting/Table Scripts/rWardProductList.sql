-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	2Jul14
-- Ref:				88922
-- Description:		Added new rWardProductListLine table this replaces rWSupplier for sypplier type L
-- =======================================================================================================
-- 24Feb15 XN Removed notes, and added VisibleToWard

IF OBJECT_ID('rWardProductList') IS NOT NULL
	DROP TABLE rWardProductList
GO

CREATE TABLE rWardProductList
(
	[WWardProductListID]    [int]               NOT NULL,
	SiteNumber              [int]               NULL,
	[SiteID]                int                 NULL,
	[Code]                  [varchar](5)        NOT NULL,		
	[Description]           [varchar](15)       NOT NULL,
	[FullName]              [varchar](35)       NOT NULL,
	PrintDeliveryNote       bit                 NOT NULL,
    PrintPickTicket         bit                 NOT NULL,
    WCustomerID             int                 NULL,
    InUse                   bit                 NOT NULL,
	VisibleToWard			bit					NOT NULL
 	CONSTRAINT rWardProductList_Unique_Code_SiteNumber UNIQUE  NONCLUSTERED 
	(
		[Code],
		[SiteNumber]
	)
)