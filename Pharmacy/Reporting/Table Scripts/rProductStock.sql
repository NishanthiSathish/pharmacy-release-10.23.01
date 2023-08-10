-- =======================================================================================================
-- Author:			Paul Crawford (PJC)
-- Amended date:	20Aug09
-- Ref:			F0050136
-- Description:		Alters the LedgerCode field in the rProductStock in the reporting database 
--			from 7 to 20 characters.

-- Author:		Paul Crawford (PJC)
-- Amended date:	15Oct09
-- Ref:			F0066390
-- Description:		Added Message field from ProductStock table.

-- Author:		Paul Crawford (PJC)
-- Amended date:	26Nov09
-- Ref:			F0068262
-- Description:		Added Stocked field from ProductStock table.
--12Apr10 AJK F0072782 Added new fields
--19May15 XN  98073 added new fields
--29Apr16 XN  151864 Added fields LabelFormat, minissue, maxissue, IssueWholePack, LiveStockCtrl, StoresPack, TherapheuticCode
--05May16 XN  151864 Fixed TherapeuticCode spelling mistake after code review 
-- =======================================================================================================


IF OBJECT_ID('rProductStock') IS NOT NULL
	DROP TABLE rProductStock
GO

CREATE TABLE rProductStock(
		[ProductStockID] int PRIMARY KEY not null,
		[DrugID] int NULL,
		[LocationID_Site] int , --this is the 15,19,20 number not the 435 etc
		[Site] int ,
		[AnnualUse] varchar(9) ,
		[ReOrderLevel] float NULL, 	
		[ReOrderQuantity] float NULL,	
		[StockLevel] varchar(9) ,
		[InUse] varchar(1) ,
		[formulary] varchar(1) ,
		[OrderCycle] varchar(2) NULL,
		[SupCode] varchar(5) NULL,
		[LastOrdered] DateTime NULL,		
		[StockTakeStatus] varchar(1) NULL,
		[Cost] Money ,
		[LossesGains] float ,
		[Local] varchar(20) NULL,
		[BatchTracking] varchar(1) ,
		[LastIssued] DateTime NULL,		
		[LastStockTakeDate] DateTime NULL,	
--		[LastStockTakeTime] varchar(6) NULL,	--added time aswell
		[LedgerCode] varchar(20) ,
		[UseThisPeriod] float ,
		[DateLastPeriodEnd] DateTime NULL,
		[loccode] varchar(3) NULL, 	
		[loccode2] varchar(3) NULL, 
		[NSVCode] varchar (7) NULL,
		[Message] Varchar (30) NULL,
		[Stocked] Varchar (1) NULL,
		[DDDValue] varchar(10) NULL,
		[DDDUnits] varchar(10) NULL,
		[UserField1] varchar(10) NULL,
		[UserField2] varchar(10) NULL,
		[UserField3] varchar(10) NULL,
		[HIProduct] char(1) NULL,
		[PIPCode] varchar(7) NULL,
		[MasterPIP] varchar(7) NULL,
		[EDILinkCode] varchar(13) NULL,
		[PNExclude] bit NOT NULL,						-- XN 19May15 Added missing item
		[EyeLabel] bit NULL,							-- XN 19May15 Added missing item
		[PSOLabel] bit NULL,							-- XN 19May15 Added missing item
		[ExpiryWarnDays] int NULL,						-- XN 19May15 Added missing item
		[LabelDescriptionInPatient] varchar(56) NULL,	-- XN 19May15 98073
		[LabelDescriptionOutPatient] varchar(56) NULL,	-- XN 19May15 98073
		[LocalDescription] varchar(56) NULL,				-- XN 19May15 98073
		LabelFormat varchar (1) NULL ,
		minissue varchar (4) NULL ,
		maxissue varchar (5) NULL ,
		IssueWholePack varchar (1) NULL ,
		LiveStockCtrl varchar (1) NULL ,
		StoresPack varchar (5) NULL ,
		TherapeuticCode varchar (2) NULL
	)
GO

-- =======================================================================================================
-- Author:	Aidan Kent (AK)
-- Create date: 04nov08
-- Ref:		F0036909
-- Description:	Create index for joins used by Cognos reporting
-- =======================================================================================================

IF exists (SELECT * from sysindexes where name = N'IX_rProductStock_SiteNSVCode' and id = object_id(N'[rProductStock]'))
DROP INDEX [rProductStock].[IX_rProductStock_SiteNSVCode]
GO
CREATE INDEX [IX_rProductStock_SiteNSVCode] ON [rProductStock]([Site],[NSVCode]) ON [PRIMARY]
GO
