--02Nov10 AJK F0086901 Created
--04Nov14 JKu TFS 103429 - rReconcil table is now truncated before repopulated


SET ANSI_NULLS ON
GO

IF OBJECT_ID('pReport_Update_rReconcil') IS NOT NULL
	DROP PROCEDURE pReport_Update_rReconcil
GO


CREATE PROCEDURE pReport_Update_rReconcil

AS

Begin

DECLARE @LiveDB				VARCHAR(max)
DECLARE @TEXT 				VARCHAR(8000)

PRINT 'Running pReport_Update_rReconcil'

--Get the live database name from the rDatabase table
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

--Do delete here first, easier than doing an update join
--04Nov14 JKu removed. NB: This was never executed originally!!!
--SET @TEXT = '
--	DELETE 
--		r
--	FROM
--		rReconcil r
--	INNER JOIN
--		' + @LiveDB + '.icwsys.wReconcil w
--	ON
--		r.wReconcilID = w.wReconcilID'

truncate table rReconcil

--Now insert new records
SET @TEXT = '
	INSERT INTO rReconcil (
		[WReconcilID],
		[RevisionLevel],
		[Code],
		[Outstanding],
		[OrdDate],
		[OrdTime],
		[LocCode],
		[SupCode],
		[Status],
		[NumPrefix],
		[Num],
		[Cost],
		[PickNo],
		[Received],
		[RecDate],
		[RecTime],
		[InvNum],
		[PayDate],
		[QtyOrdered],
		[Urgency],
		[ToFollow],
		[InternalSiteNo],
		[InternalMethod],
		[SupplierType],
		[ConvFact],
		[IssueUnits],
		[Stocked],
		[Description],
		[PFlag],
		[CreatedUser],
		[CustOrdNo],
		[VATamount],
		[VatRateCode],
		[VatRatePct],
		[VatInclusive],
		[InDispute],
		[InDisputeUser],
		[ShelfPrinted],
		[Pad],
		[crlf],
		[SiteID],
		[CodingSlipDate],
		[ReconcileDate],
		[SessionLock],
		[DeliveryNoteReference])
	
	SELECT
		w.[WReconcilID],
		w.[RevisionLevel],
		w.[Code],
		w.[Outstanding],
		w.[OrdDate],
		w.[OrdTime],
		w.[LocCode],
		w.[SupCode],
		w.[Status],
		w.[NumPrefix],
		w.[Num],
		w.[Cost],
		w.[PickNo],
		w.[Received],
		w.[RecDate],
		w.[RecTime],
		w.[InvNum],
		w.[PayDate],
		w.[QtyOrdered],
		w.[Urgency],
		w.[ToFollow],
		w.[InternalSiteNo],
		w.[InternalMethod],
		w.[SupplierType],
		w.[ConvFact],
		w.[IssueUnits],
		w.[Stocked],
		w.[Description],
		w.[PFlag],
		w.[CreatedUser],
		w.[CustOrdNo],
		w.[VATamount],
		w.[VatRateCode],
		w.[VatRatePct],
		w.[VatInclusive],
		w.[InDispute],
		w.[InDisputeUser],
		w.[ShelfPrinted],
		w.[Pad],
		w.[crlf],
		w.[SiteID],
		w.[CodingSlipDate],
		w.[ReconcileDate],
		w.[SessionLock],
		w.[DeliveryNoteReference]
	FROM
		' + @LiveDB + '.icwsys.wReconcil w
	LEFT JOIN
		rReconcil r on w.wReconcilID = r.wReconcilID
	WHERE
		r.wReconcilID is null' 

EXECUTE (@TEXT)

PRINT ''

End

GO
