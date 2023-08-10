-- 14Feb13 XN 30286 Added PN to reporting db
-- 21Jan16 TH 138337 Added DaysRequested

IF OBJECT_ID('rPNSupplyRequest') IS NOT NULL
	DROP TABLE rPNSupplyRequest
GO

CREATE TABLE [rPNSupplyRequest](
	[RequestID] [int] NOT NULL,
	[RequestID_Parent] [int] NOT NULL,
	[BatchNumber] [varchar](30) NULL,
	[AdminStartDate] [datetime] NULL,
	[NumberOfLabelsAminoCombined] [int] NULL,
	[NumberOfLabelsLipid] [int] NULL,
	[BaxaCompounder] [bit] NULL,
	[BaxaIncludeLipid] [bit] NULL,
	[PreperationDate] [datetime] NOT NULL,
	[ExpiryDaysAqueousCombined] [int] NOT NULL,
	[ExpiryDaysLipid] [int] NULL,

 	[Description] varchar(256) NOT NULL,
	
	Creator_EntityID [int] NOT NULL,
	Creator_Initials varchar(10) NULL,
	CreatedDate datetime NOT NULL,
	EpisodeID int NOT NULL,
	Patient_EntityID int NOT NULL,
	
	[Request Cancellation] bit NOT NULL,
	Request_Cancellation__EntityID int NULL,
	Request_Cancellation__Initials varchar(10) NULL,
	Request_Cancellation__CreatedDate datetime NULL,
	
	PNPrinted bit NOT NULL,
	PNPrinted__EntityID int NULL, 
	PNPrinted__Initials varchar(10) NULL, 
	PNPrinted__CreatedDate datetime NULL,
	
	PNIssued bit NOT NULL,
	PNIssued__EntityID int NULL, 
	PNIssued__Initials varchar(10) NULL, 
	PNIssued__CreatedDate datetime NULL,
	
	PNSupplyFlag1 bit NOT NULL,
	PNSupplyFlag1__EntityID int NULL, 
	PNSupplyFlag1__Initials varchar(10) NULL, 
	PNSupplyFlag1__CreatedDate datetime NULL,
	
	PNSupplyFlag2 bit NOT NULL,
	PNSupplyFlag2__EntityID int NULL, 
	PNSupplyFlag2__Initials varchar(10) NULL, 
	PNSupplyFlag2__CreatedDate datetime NULL,
	
	PNSupplyFlag3 bit NOT NULL,
	PNSupplyFlag3__EntityID int NULL, 
	PNSupplyFlag3__Initials varchar(10) NULL, 
	PNSupplyFlag3__CreatedDate datetime NULL, 
	
	Complete bit NOT NULL,

	DaysRequested int NULL

CONSTRAINT [PK_rPNSupplyRequest] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_rPNSupplyRequest_Patient_EntityID_EpisodeID] ON [rPNSupplyRequest] 
(
    Patient_EntityID, 
	EpisodeID
)
GO

CREATE NONCLUSTERED INDEX [IX_rPNSupplyRequest_RequestID_Parent] ON [rPNSupplyRequest] 
(
	[RequestID_Parent]
)
GO
