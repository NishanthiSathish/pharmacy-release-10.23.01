-- 14Feb13 XN 30286 Added PN to reporting db

IF OBJECT_ID('rPNPrescription') IS NOT NULL
	DROP TABLE rPNPrescription
GO

CREATE TABLE [rPNPrescription](
	[RequestID] [int] NOT NULL,
	[DosingWeight_kg] [float] NOT NULL,
	[PerKiloRules] [bit] NOT NULL,
	[CentralLinePresent] [bit] NOT NULL,
	[Supply48Hours] [bit] NOT NULL,
	[RegimenName] [varchar](90) NULL,
	[Volume_ml] [float] NULL,
	[Nitrogen_grams] [float] NULL,
	[Glucose_grams] [float] NULL,
	[Fat_grams] [float] NULL,
	[Sodium_mmol] [float] NULL,
	[Potassium_mmol] [float] NULL,
	[Calcium_mmol] [float] NULL,
	[Magnesium_mmol] [float] NULL,
	[Zinc_micromol] [float] NULL,
	[Phosphate_mmol] [float] NULL,
	[Selenium_nanomol] [float] NULL,
	[Copper_micromol] [float] NULL,
	[Iron_micromol] [float] NULL,
	[AqueousVitamins_mL] [float] NULL,
	[LipidVitamins_mL] [float] NULL,
	
	[Description] varchar(256) NOT NULL,
	
	Creator_EntityID [int] NOT NULL,
	Creator_Initials varchar(10) NULL,
	CreatedDate datetime NOT NULL,
	EpisodeID int NOT NULL,
	Patient_EntityID int NOT NULL,
	
	Duration int NULL,
	UnitID_Duration int NULL,
	UnitID_Duration_Description varchar(50) NULL,
	
	StartDate_Prescription datetime NOT NULL,
	StopDate_Prescription datetime NULL,
	
	[Request Cancellation] bit NOT NULL,
	Request_Cancellation__EntityID int NULL,
	Request_Cancellation__Initials varchar(10) NULL,
	Request_Cancellation__CreatedDate datetime NULL
	
 CONSTRAINT [PK_rPNPrescription] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
) ON [PRIMARY])
GO

CREATE NONCLUSTERED INDEX [IX_rPNPrescription_Patient_EntityID_EpisodeID] ON [rPNPrescription] 
(
    Patient_EntityID,
    EpisodeID
)
GO
