-- 25May16 KR 39882 Added AMM to reporting db

IF OBJECT_ID('rAMMPrescription') IS NOT NULL
	DROP TABLE rAMMPrescription
GO

CREATE TABLE [rAMMPrescription](
	[RequestID] [int] NOT NULL,
	[Description] varchar(256) NOT NULL,
	EpisodeID int NOT NULL,
	Patient_EntityID int NOT NULL,
	Creator_EntityID [int] NOT NULL,
	Creator_Initials varchar(10) NULL,
	CreatedDate datetime NOT NULL,
	Duration int NULL,
	UnitID_Duration int NULL,
	UnitID_Duration_Description varchar(50) NULL,
	StartDate_Prescription datetime NOT NULL,
	StopDate_Prescription datetime NULL,
	[Request Cancellation] bit NOT NULL,
	Request_Cancellation__EntityID int NULL,
	Request_Cancellation__Initials varchar(10) NULL,
	Request_Cancellation__CreatedDate datetime NULL,
	AMMForManufacture__EntityID int NULL,
	AMMForManufacture__Initials varchar(10) NULL,
	AMMForManufacture__CreatedDate datetime NULL,
	AMMManufactureComplete bit NULL,
	AMMManufactureComplete__EntityID int NULL,
	AMMManufactureComplete__Initials varchar(10) NULL,
	AMMManufactureComplete__CreatedDate datetime NULL

 CONSTRAINT [PK_rAMMPrescription] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
) ON [PRIMARY])
GO

CREATE NONCLUSTERED INDEX [IX_rAMMPrescription_Patient_EntityID_EpisodeID] ON [rAMMPrescription] 
(
    Patient_EntityID,
    EpisodeID
)
GO
