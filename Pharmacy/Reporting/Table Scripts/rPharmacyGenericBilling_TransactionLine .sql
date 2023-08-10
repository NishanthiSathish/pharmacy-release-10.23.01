-- =======================================================================================================
-- Author:		Tony Houlihan
-- Create date:		07Jan14
-- Ref:			77893
-- Description:		Added rPharmacyGenericBilling_TransactionLine structure
-- =======================================================================================================

IF OBJECT_ID('rPharmacyGenericBilling_TransactionLine') IS NOT NULL
	DROP TABLE rPharmacyGenericBilling_TransactionLine
GO

CREATE TABLE rPharmacyGenericBilling_TransactionLine(
	[PharmacyGenericBilling_TransactionLineID] [int] NOT NULL,
	[RequestID_Dispensing] [int] NULL,
	[PrescriptionID] [int] NULL,
	[BasePrescriptionID] [int] NULL,
	[NSVCode] [varchar](7) NULL,
	[LineCost] [float] NULL,
	[PacksIssued] [float] NULL,
	[IssueQty] [float] NULL,
	[BaseCost] [float] NULL,
	[markup] [float] NULL,
	[CreateInits] [varchar] (3) NULL,
	[CreateDT] [datetime] NULL,
	[ProductDesc] [varchar] (56) NULL,
	[CostAdjust] [float] NULL,
	[MarkupAdjust] [float] NULL,
	[DispFee] [float] NULL,
	[DispAdjust] [float] NULL,
	[TaxRate] [float] NULL,
	[TaxAdjust] [float] NULL,
	[LineAdjust] [float] NULL,
	[PackCost] [float] NULL,
	[TaxAmount] [float] NULL,
	[SiteID] [int] NULL
	) 
GO


