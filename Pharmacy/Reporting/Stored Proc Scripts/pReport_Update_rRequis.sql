--29Apr09 TH F0052134 replaced sys with icwsys

IF OBJECT_ID('pReport_Update_rRequis') IS NOT NULL
	DROP PROCEDURE pReport_Update_rRequis
GO


CREATE PROCEDURE pReport_Update_rRequis
AS

DECLARE @TEXT 			VARCHAR (8000)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rRequis'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rRequis

SET @TEXT = 

	'INSERT INTO rRequis (
		[SiteID] ,
		[WRequisID] ,
		[Num] ,
		[PickNo] ,
		[InDisputeUser] ,
		[ShelfPrinted] ,
		[RequisitionNum] ,
		[VatRatePct] ,
		[VatInclusive] ,
		[InDispute] ,
		[CustOrdNo] ,
		[VATamount] ,
		[VatRateCode] ,
		[PFlag] ,
		[CreatedUser] ,
		[ConvFact] ,
		[IssueUnits] ,
		[Stocked] ,
		[InternalSiteNo] ,
		[InternalMethod] ,
		[SupplierType] ,
		[QtyOrdered] ,
		[Urgency] ,
		[ToFollow] ,
		[InvNum] ,
		[PayDate] ,
		[Cost] ,
		[Received] ,
		[RecDate] ,
		[SupCode] ,
		[Status] ,
		[NumPrefix] ,
		[OrdDate] ,
		[LocCode] ,
		[NSVCode] ,
		[Outstanding] 
		)

	SELECT 	

		[SiteID],
		[WRequisID],
		[Num],
		[PickNo],
		[InDisputeUser],
		[ShelfPrinted],
		[RequisitionNum],
		[VatRatePct],
		CAST(ISNULL([VatInclusive], 0) as float) / 100  VatInclusive,
		[InDispute],
		[CustOrdNo],
		CAST(ISNULL([VATamount], 0) as float) / 100  VATamount,
		[VatRateCode],
		[PFlag],
		[CreatedUser],
		[ConvFact],
		[IssueUnits],
		[Stocked],
		[InternalSiteNo],
		[InternalMethod],
		[SupplierType],
		[QtyOrdered],
		[Urgency],
		[ToFollow],
		[InvNum],
		dbo.fReport_String_To_Date([PayDate] , '''') PayDate,
		CAST(ISNULL([Cost], 0) as float) / 100 Cost,
		[Received],
		dbo.fReport_String_To_Date([RecDate], [RecTime]) RecDate,
		[SupCode],
		[Status],
		[NumPrefix],
		dbo.fReport_String_To_Date([OrdDate],[OrdTime]) OrdDate,
		[LocCode] ,
		[Code] NSVCode,
		[Outstanding]

	FROM ' + @LiveDB + '.icwsys.WRequis'

EXECUTE (@TEXT)

PRINT ''
