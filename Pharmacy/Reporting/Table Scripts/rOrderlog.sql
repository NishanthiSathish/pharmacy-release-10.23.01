-- 02Nov10 AJK F0086901 Added DateInvoiced
-- 16Aug11 TH  F0084761 Added DeliveryNoteReference


IF OBJECT_ID('rOrderlog') IS NOT NULL
	DROP TABLE rOrderlog
GO

CREATE TABLE rOrderlog (
	wOrderLogID int PRIMARY KEY NOT NULL ,
	OrderNum varchar (10) NULL ,
	ConvFact float NULL ,
	IssueUnits varchar (5) NULL ,
	DispId varchar (3) NULL ,
	Terminal varchar (15) NULL ,
	DateOrd int NULL ,
	DateRec int NULL ,
	QtyOrd varchar (13) NULL ,
	QtyRec varchar (13) NULL ,
	SupCode varchar (5) NULL ,
	BatchNum varchar (25) NULL ,
	ExpiryDate varchar (8) NULL ,
	InvNum varchar (20) NULL ,
	LinkedNum varchar (4) NULL ,
	ReasonCode varchar (4) NULL ,
	StockLvl varchar (9) NULL ,
	EntityID int NULL ,
	DateOrdered datetime NULL ,
	DateReceived datetime NULL ,
	[Month] varchar (7) NULL ,
	Site int NULL ,
	SiteID int NOT NULL ,
	NSVCode varchar (7) NULL ,
	LogDateTime datetime NULL ,
	Kind varchar (1) NULL ,
	Cost money NULL ,
	CostExTax money NULL ,
	TaxCost money NULL ,
	TaxCode varchar (1) NULL ,
	TaxRate varchar (5) NULL ,
	StockValue Float NULL ,
	DateInvoiced datetime null,
	DeliveryNoteReference varchar(30) null

)
GO


-- =======================================================================================================
-- Author:	Aidan Kent (AK)
-- Create date: 04nov08
-- Ref:		F0036909
-- Description:	Create index for joins used by Cognos reporting
-- =======================================================================================================

IF exists (SELECT * from sysindexes where name = N'IX_rOrderlog_SupCodeSite' and id = object_id(N'[rOrderlog]'))
DROP INDEX [rOrderlog].[IX_rOrderlog_SupCodeSite]
GO
CREATE INDEX [IX_rOrderlog_SupCodeSite] ON [rOrderlog]([SupCode],[Site]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rOrderlog_NSVCode' and id = object_id(N'[rOrderlog]'))
DROP INDEX [rOrderlog].[IX_rOrderlog_NSVCode]
GO
CREATE INDEX [IX_rOrderlog_NSVCode] ON [rOrderlog]([NSVCode]) ON [PRIMARY]
GO
