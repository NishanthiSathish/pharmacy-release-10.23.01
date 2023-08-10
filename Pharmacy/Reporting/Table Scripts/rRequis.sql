IF OBJECT_ID('rRequis') IS NOT NULL
	DROP TABLE rRequis
GO

CREATE TABLE rRequis (
		[SiteID] int ,
		[WRequisID] int Primary key ,
		[Num] int NULL,
		[PickNo] int NULL,
		[InDisputeUser] varchar(3) NULL,
		[ShelfPrinted] varchar(1) NULL,
		[RequisitionNum] varchar(10) NULL,
		[VatRatePct] varchar(13) NULL,
		[VatInclusive] MONEY NULL,
		[InDispute] varchar(1) NULL,
		[CustOrdNo] varchar(12) NULL,
		[VATamount] MONEY NULL,
		[VatRateCode] varchar(1) NULL,
		[PFlag] varchar(1) NULL,
		[CreatedUser] varchar(3) NULL,
		[ConvFact] varchar(5) NULL,
		[IssueUnits] varchar(5) NULL,
		[Stocked] varchar(1) NULL,
		[InternalSiteNo] varchar(3) NULL,
		[InternalMethod] varchar(1) NULL,
		[SupplierType] varchar(1) NULL,
		[QtyOrdered] varchar(13) NULL,
		[Urgency] varchar(1) NULL,
		[ToFollow] varchar(1) NULL,
		[InvNum] varchar(20) NULL,
		[PayDate] DATETIME NULL,
		[Cost] MONEY NULL,
		[Received] varchar(13) NULL,
		[RecDate] DATETIME NULL,
		[SupCode] varchar(5) NULL,
		[Status] varchar(1) NULL,
		[NumPrefix] varchar(6) NULL,
		[OrdDate] DATETIME NULL,
		[LocCode] varchar(3) NULL,
		[NSVCode] varchar(7) NULL,
		[Outstanding] varchar(13) NULL
		) 
GO
