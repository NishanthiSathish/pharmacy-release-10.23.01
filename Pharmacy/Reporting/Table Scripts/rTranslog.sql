--04Mar08 JKu Changed length of BatchNum to 255 long
--24Aug11 TH Added prescription reason TFS12007
--14May12 TH Added NHNumber and NHNumberValid TFS26711
--14May12 TH Extended Consultant (TFS)
--08Jan15 TH Added WWardProductListItemID

IF OBJECT_ID('rTranslog') IS NOT NULL
	DROP TABLE rTranslog
GO

CREATE TABLE rTranslog (
	WTranslogID int PRIMARY KEY NOT NULL ,
	[Month] varchar (7) NULL ,
	Site int NULL ,
	NSVCode varchar (7) NULL ,
	LogDateTime datetime NULL ,
	Kind varchar (1) NULL ,
	LabelType varchar (1) NULL ,
	CaseNo varchar (10) NULL ,
	PatId varchar (10) NULL ,
	IssueUnits varchar (5) NULL ,
	ConvFact varchar (5) NULL ,
	DispId varchar (3) NULL ,
	Terminal varchar (15) NULL ,
	IssueDate datetime NULL ,
	Qty float NULL ,
	Cost money NULL ,
	CostExTax money NULL ,
	TaxCost money NULL ,
	TaxCode varchar (1) NULL ,
	TaxRate float NULL ,
	Ward varchar (5) NULL ,
	Consultant varchar (10) NULL ,
	Specialty varchar (5) NULL ,
	Prescriber varchar (5) NULL ,
	DirCode varchar (255) NULL ,
	Containers float NULL ,
	Episode int NULL ,
	EventNumber varchar (10) NULL ,
	PrescriptionNum varchar (10) NULL ,
	BatchNum varchar (255) NULL ,
	ExpiryDate varchar (8) NULL ,
	PPFlag varchar (1) NULL ,
	StockLvl float NULL ,
	CustOrdNo varchar (12) NULL ,
	CivasType varchar (1) NULL ,
	CivasAmount float NULL ,
	SiteID int NULL ,
	EntityID int NULL ,
	ProductID int NULL ,
	BNFCode varchar (14) NULL ,
	EntityID_GP INT NULL,
	RequestID_Prescription  INT NULL,
	PrescriberID  INT NULL,
	RequestID_Dispensing INT NULL,
	StockValue Float NULL,
	PCT bit NULL,
	EpisodeDescription varchar(128) NULL,
	PrescriptionReason varchar(1024) NULL,
	NHNumber varchar(10) NULL,
	NHNumberValid bit NULL,
	WWardProductListItemID int NULL
)
GO


-- =======================================================================================================
-- Author:	Aidan Kent (AK)
-- Create date: 04nov08
-- Ref:		F0036909
-- Description:	Create index for joins used by Cognos reporting
-- =======================================================================================================

IF exists (SELECT * from sysindexes where name = N'IX_rTranslog_WardSite' and id = object_id(N'[rTranslog]'))
DROP INDEX [rTranslog].[IX_rTranslog_WardSite]
GO
CREATE INDEX [IX_rTranslog_WardSite] ON [rTranslog]([Ward],[Site]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rTranslog_Consultant' and id = object_id(N'[rTranslog]'))
DROP INDEX [rTranslog].[IX_rTranslog_Consultant]
GO
CREATE INDEX [IX_rTranslog_Consultant] ON [rTranslog]([Consultant]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rTranslog_PatID' and id = object_id(N'[rTranslog]'))
DROP INDEX [rTranslog].[IX_rTranslog_PatID]
GO
CREATE INDEX [IX_rTranslog_PatID] ON [rTranslog]([PatID]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rTranslog_Specialty' and id = object_id(N'[rTranslog]'))
DROP INDEX [rTranslog].[IX_rTranslog_Specialty]
GO
CREATE INDEX [IX_rTranslog_Specialty] ON [rTranslog]([Specialty]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rTranslog_EntityID_GP' and id = object_id(N'[rTranslog]'))
DROP INDEX [rTranslog].[IX_rTranslog_EntityID_GP]
GO
CREATE INDEX [IX_rTranslog_EntityID_GP] ON [rTranslog]([EntityID_GP]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rTranslog_NSVCode' and id = object_id(N'[rTranslog]'))
DROP INDEX [rTranslog].[IX_rTranslog_NSVCode]
GO
CREATE INDEX [IX_rTranslog_NSVCode] ON [rTranslog]([NSVCode]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rTranslog_NSVCodeSite' and id = object_id(N'[rTranslog]'))
DROP INDEX [rTranslog].[IX_rTranslog_NSVCodeSite]
GO
CREATE INDEX [IX_rTranslog_NSVCodeSite] ON [rTranslog]([NSVCode],[Site]) ON [PRIMARY]
GO
