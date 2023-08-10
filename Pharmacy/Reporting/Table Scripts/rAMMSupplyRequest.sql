-- 25May16 KR 39882 Added AMM to reporting db

IF OBJECT_ID('rAMMSupplyRequest') IS NOT NULL
	DROP TABLE rAMMSupplyRequest
GO

CREATE TABLE [rAMMSupplyRequest](
	RequestID int NOT NULL,
	SiteID int NOT NULL,
	WFormulaID int NOT NULL,
	NSVCode varchar(7) NOT NULL,
	BatchNumber varchar(20) NOT NULL,
	ProductionTrayBarcode varchar(20) NOT NULL,
	ManufactureDate datetime NULL,
	[State] int NOT NULL,
	[Priority] bit NOT NULL,
	VolumeType char(1) NOT NULL,
	VolumeOfInfusion_mL float NULL,
	SyringeFillType char(1) NOT NULL DEFAULT (''),
	Dose float NOT NULL,
	UnitID_Dose int NOT NULL,
	ManufactureShiftID int NULL,
	SecondCheckType char(2) NOT NULL DEFAULT (''),
	CompoundingDate datetime NULL,
	EntityID_LastStateUpdate int NOT NULL DEFAULT ((0)),
	DateTime_LastStateUpdate datetime NOT NULL,
	RequestID_WLabel int NULL,
	IssueState char(1) NOT NULL DEFAULT (''),
	EpisodeTypeID int NOT NULL,
	PrescriptionId int NOT NULL DEFAULT ((0)),
	EpisodeId int NOT NULL,
	Patient_EntityID int NOT NULL,
	Creator_EntityID [int] NOT NULL,
	Creator_Initials varchar(10) NULL,
	CreatedDate datetime NOT NULL,
	[Request Cancellation] bit NOT NULL,
	Request_Cancellation__EntityID int NULL,
	Request_Cancellation__Initials varchar(10) NULL,
	Request_Cancellation__CreatedDate datetime NULL,
	Complete bit NULL,
	QuantityRequested float NULL,
	UnitID_Quantity int NULL,
	Stage_Schedule_EntityID int NULL,
	Stage_Schedule_CreatedDate datetime NULL,
	Stage_Schedule_Initials varchar(10) NULL,
	Stage_ProductionTray_EntityID int NULL,
	Stage_ProductionTray_CreatedDate datetime NULL,
	Stage_ProductionTray_Initials varchar(10) NULL,
	Stage_Assembly_EntityID int NULL,
	Stage_Assembly_CreatedDate datetime NULL,
	Stage_Assembly_Initials varchar(10) NULL,
	Stage_Check_EntityID int NULL,
	Stage_Check_CreatedDate datetime NULL,
	Stage_Check_Initials varchar(10) NULL,
	Stage_Compound_EntityID int NULL,
	Stage_Compound_CreatedDate datetime NULL,
	Stage_Compound_Initials varchar(10) NULL,
	Stage_Label_EntityID int NULL,
	Stage_Label_CreatedDate datetime NULL,
	Stage_Label_Initials varchar(10) NULL,
	Stage_Final_EntityID int NULL,
	Stage_Final_CreatedDate datetime NULL,
	Stage_Final_Initials varchar(10) NULL,
	Stage_BondStore_EntityID int NULL,
	Stage_BondStore_CreatedDate datetime NULL,
	Stage_BondStore_Initials varchar(10) NULL,
	Stage_Release_EntityID int NULL,
	Stage_Release_CreatedDate datetime NULL,
	Stage_Release_Initials varchar(10) NULL,
	Stage_Complete_EntityID int NULL,
	Stage_Complete_CreatedDate datetime NULL,
	Stage_Complete_Initials varchar(10) NULL

 CONSTRAINT [PK_rAMMSupplyRequest] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
) ON [PRIMARY])
GO

CREATE NONCLUSTERED INDEX [IX_rAMMSupplyRequest_Patient_EntityID_EpisodeID] ON [rAMMSupplyRequest] 
(
    Patient_EntityID,
    EpisodeID
)
GO
