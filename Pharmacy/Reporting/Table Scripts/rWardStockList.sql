-- 
-- Note that this table is now redundent (though will still be correctly updated )
-- You should now use rSupplier2, rCustomer, or rWardProductList instead
-- 
-- 2Jul14 XN 88922
-- 7Nov16 XN 167435 changed [TopupLvl], and [LastIssue] from smallint to int

-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	12May10
-- Ref:				F0077891
-- Description:		Adds the rWardStockList to the reporting database.
-- =======================================================================================================
IF OBJECT_ID('rWardStockList') IS NOT NULL
	DROP TABLE rWardStockList
GO

CREATE TABLE rWardStockList (
	[ScreenPosn] [int] NULL,
	[NSVcode] [varchar](7) NULL,
	[TitleText] [varchar](56) NULL,
	[PrintLabel] [varchar](1) NULL,
	[SiteName] [varchar](5) NULL,
	[TopupLvl] [int] NULL,
	[LastIssue] [int] NULL,
	[PackSize] [int] NULL,
	[LastIssueDate] datetime NULL,
	[LocalCode] [varchar](7) NULL,
	[SiteID] [int] NULL,
	[Barcode] [varchar](15) NULL,
	[DailyIssue] [int] NULL,
	[WWardStockListID] [int] PRIMARY KEY NOT NULL,  -- XN 01Jul10 F0090674 prevent it from being an identity column
	[WSupplierID] [int] NULL
)
GO

IF exists (SELECT * from sysindexes where name = N'IX_rWardStockList_SiteNSVCode' and id = object_id(N'[rWardStockList]'))
DROP INDEX [rWardStockList].[IX_rWardStockList_SiteNSVCode]
GO
CREATE INDEX [IX_rWardStockList_SiteNSVCode] ON [rWardStockList]([SiteID],[NSVCode]) ON [PRIMARY]
GO



