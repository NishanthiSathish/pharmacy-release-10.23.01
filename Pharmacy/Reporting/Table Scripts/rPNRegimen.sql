-- 14Feb13 XN 30286 Added PN to reporting db

IF OBJECT_ID('rPNRegimen') IS NOT NULL
	DROP TABLE rPNRegimen
GO

CREATE TABLE [rPNRegimen](
	[RequestID] [int] NOT NULL,
	[RequestID_Parent] [int] NOT NULL,
	[LocationID_Site] [int] NOT NULL,
	[Volume_mL] [float] NULL,
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
	[IsCombined] [bit] NOT NULL,
	[CentralLineOnly] [bit] NOT NULL,
	[InfusionHoursAqueousOrCombined] [float] NOT NULL,
	[InfusionHoursLipid] [float] NOT NULL,
	[SupplyLipidSyringe] [bit] NOT NULL,
	[Supply48Hours] [bit] NOT NULL,
	[OverageAqueousOrCombined] [float] NULL,
	[OverageLipid] [float] NULL,
	
	[LastModDate] [datetime] NOT NULL,
	[LastModEntityID_User] [int] NOT NULL,
	[LastModEntity_Initials] varchar(10) NULL,		
	[LastModTerminal] [int] NOT NULL,
	[LastModTerminal_Name] varchar(15) NULL,
	
	[NumberOfSyringes] [int] NOT NULL,
	[ModificationNumber] [int] NOT NULL,
	
    TotalVolume_mL [float] NULL,
    TotalCalories_kcals [float] NULL,
    TotalNitrogen_grams [float] NULL,
    TotalGlucose_grams [float] NULL,
    TotalFat_grams [float] NULL,
    TotalSodium_mmol [float] NULL,
    TotalPotassium_mmol [float] NULL,
    TotalCalcium_mmol [float] NULL,
    TotalMagnesium_mmol [float] NULL,
    TotalZinc_micromol [float] NULL,
    TotalPhosphate_mmol [float] NULL,
    TotalChloride_mmol [float] NULL,
    TotalAcetate_mmol [float] NULL,
    TotalSelenium_nanomol [float] NULL,
    TotalCopper_micromol [float] NULL,
    TotalIron_micromol [float] NULL,
    TotalVolume_mLPerkg [float] NULL,
    TotalCalories_kcalsPerkg [float] NULL,
    TotalNitrogen_gramsPerkg [float] NULL,
    TotalGlucose_gramsPerkg [float] NULL,
    TotalFat_gramsPerkg [float] NULL,
    TotalSodium_mmolPerkg [float] NULL,
    TotalPotassium_mmolPerkg [float] NULL,
    TotalCalcium_mmolPerkg [float] NULL,
    TotalMagnesium_mmolPerkg [float] NULL,
    TotalZinc_micromolPerkg [float] NULL,
    TotalPhosphate_mmolPerkg [float] NULL,
    TotalChloride_mmolPerkg [float] NULL,
    TotalAcetate_mmolPerkg [float] NULL,
    TotalSelenium_nanomolPerkg [float] NULL,
    TotalCopper_micromolPerkg [float] NULL,
    TotalIron_micromolPerkg [float] NULL,	
    
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
	
	[PNAuthorised] bit NOT NULL,
	PNAuthorised__EntityID int NULL,
	PNAuthorised__Initials varchar(10) NULL,
	PNAuthorised__CreatedDate datetime NULL
 CONSTRAINT [PK_rPNRegimen] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_rPNRegimen_Patient_EntityID_EpisodeID] ON [rPNRegimen] 
(
    Patient_EntityID,
    [EpisodeID]
)
GO

CREATE NONCLUSTERED INDEX [IX_rPNRegimen_RequestID_Parent] ON [rPNRegimen] 
(
    [RequestID_Parent]
)
GO