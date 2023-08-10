-- 02Nov10 AJK F0086901 Created
-- 26Sep14 XN  99425 Converted PickNo from smallint to  int

IF OBJECT_ID('rReconcil') IS NOT NULL
	DROP TABLE rReconcil
GO

CREATE TABLE [rReconcil](
	[WReconcilID] [int] PRIMARY KEY NOT NULL,
	[RevisionLevel] [varchar](2) NULL,
	[Code] [varchar](7) NULL,
	[Outstanding] [varchar](13) NULL,
	[OrdDate] [varchar](8) NULL,
	[OrdTime] [varchar](6) NULL,
	[LocCode] [varchar](3) NULL,
	[SupCode] [varchar](5) NULL,
	[Status] [varchar](1) NULL,
	[NumPrefix] [varchar](6) NULL,
	[Num] [int] NULL,
	[Cost] [varchar](13) NULL,
	[PickNo] [int] NULL,
	[Received] [varchar](13) NULL,
	[RecDate] [varchar](8) NULL,
	[RecTime] [varchar](6) NULL,
	[InvNum] [varchar](20) NULL,
	[PayDate] [varchar](8) NULL,
	[QtyOrdered] [varchar](13) NULL,
	[Urgency] [varchar](1) NULL,
	[ToFollow] [varchar](1) NULL,
	[InternalSiteNo] [varchar](3) NULL,
	[InternalMethod] [varchar](1) NULL,
	[SupplierType] [varchar](1) NULL,
	[ConvFact] [varchar](5) NULL,
	[IssueUnits] [varchar](5) NULL,
	[Stocked] [varchar](1) NULL,
	[Description] [varchar](56) NULL,
	[PFlag] [varchar](1) NULL,
	[CreatedUser] [varchar](3) NULL,
	[CustOrdNo] [varchar](12) NULL,
	[VATamount] [varchar](13) NULL,
	[VatRateCode] [varchar](1) NULL,
	[VatRatePct] [varchar](13) NULL,
	[VatInclusive] [varchar](13) NULL,
	[InDispute] [varchar](1) NULL,
	[InDisputeUser] [varchar](3) NULL,
	[ShelfPrinted] [varchar](1) NULL,
	[Pad] [varchar](757) NULL,
	[crlf] [varchar](2) NULL,
	[SiteID] [int] NOT NULL,
	[CodingSlipDate] [varchar](10) NULL,
	[ReconcileDate] [varchar](10) NULL,
	[SessionLock] [int] NOT NULL,
	[DeliveryNoteReference] [varchar](20) NULL
)
GO

