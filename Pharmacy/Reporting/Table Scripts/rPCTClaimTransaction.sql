-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added De-normalised PCTClaimTransaction structure
-- =======================================================================================================

IF OBJECT_ID('rPCTClaimTransaction') IS NOT NULL
	DROP TABLE rPCTClaimTransaction
GO

CREATE TABLE rPCTClaimTransaction (
	[PCTClaimTransactionID] [int] NOT NULL,
	[PCTClaimFileID] [int] NULL,
	[PCTClaimFile_DataSpecificationRelease] [char](3) NULL,
	[PCTClaimFile_SLANumber] [varchar](7) NULL,
	[PCTClaimFile_Generated] [datetime] NULL,
	[PCTClaimFile_System] [varchar](10) NULL,
	[PCTClaimFile_SystemVersion] [varchar](6) NULL,
	[PCTClaimFile_ScheduleDate] [datetime] NULL,
	[PCTClaimFile_ClaimDate] [datetime] NULL,
	[PCTClaimFile_FileID] [int] NULL,
	[PCTClaimFile_SiteID] [int] NULL,
	[SiteNumber] [int] NULL,
	[SitE_Description] [varchar](128) NULL,
	[Site_Details] [varchar](1024) NULL,
	[Category] [char](1) NULL,
	[ComponentNumber] [int] NULL,
	[TotalComponentNumber] [int] NULL,
	[PrescriberID] [varchar](10) NULL,
	[HealthProfessionalGroupCode] [char](2) NULL,
	[SpecialistID] [varchar](10) NULL,
	[EndorsementDate] [datetime] NULL,
	[PrescriberFlag] [char](1) NULL,
	[PCTOncologyPatientGrouping] [char](1) NULL,
	[NHI] [char](7) NULL,
	[PCTPatientCategory] [char](1) NULL,
	[PCTPatientCategoryID] [int] NULL,
	[PCTPatientCategory_Description] [varchar](100) NULL,
	[PCTPatientCategory_Details] [varchar](max) NULL,
	[CSCorPHOStatusFlag] [char](1) NULL,
	[HUHCStatusFlag] [bit] NULL,
	[SpecialAuthorityNumber] [varchar](10) NULL,
	[Dose] [decimal](10, 4) NULL,
	[DailyDose] [decimal](38, 4) NULL,
	[PrescriptionFlag] [bit] NULL,
	[DoseFlag] [bit] NULL,
	[PrescriptionID] [varchar](9) NULL,
	[ServiceDate] [datetime] NULL,
	[ClaimCode] [int] NULL,
	[PCTProduct_BrandCode] [int] NULL,
	[PCTProduct_BrandName] [nvarchar](40) NULL,
	[PCTProduct_FormulationName] [nvarchar](200) NULL,
	[PCTProduct_ChemicalName] [nvarchar](220) NULL,
	[PCTProduct_Quantity] [real] NULL,
	[PCTProduct_Multiple] [real] NULL,
	[PCTProduct_Specified] [bit] NULL,
	[PCTProduct_Subsidy] [decimal](19, 4) NULL,
	[PCTProduct_Alternate] [decimal](19, 4) NULL,
	[PCTProduct_Price] [decimal](19, 4) NULL,
	[PCTProduct_CBS] [bit] NULL,
	[PCTProduct_OP] [bit] NULL,
	[PCTProduct_SpecialType] [nvarchar](25) NULL,
	[PCTProduct_SpecialEndorsementType] [nvarchar](25) NULL,
	[PCTProduct_DrugFileDate] [datetime] NULL,
	[PCTProduct_Units] [varchar](5) NULL,
	[PCTProduct_PCTProductID] [int] NULL,
	[PCTProduct_PCTMasterProductID] [int] NULL,
	[QuantityClaimed] [decimal](10, 4) NULL,
	[PackUnitOfMeasure] [varchar](8) NULL,
	[ClaimAmount] [int] NULL,
	[CBSSubsidy] [int] NULL,
	[CBSPacksize] [decimal](10, 4) NULL,
	[Funder] [char](3) NULL,
	[FormNumber] [varchar](9) NULL,
	[ParentID] [int] NULL,
	[SupersededDate] [datetime] NULL,
	[SupersededByEntityID] [int] NULL,
	[SupersededByName] [varchar](128) NULL,
	[ScheduleDate] [datetime] NULL,
	[RequestID_Prescription] [int] NULL,
	[PCTPrescriptionID] [int] NULL,
	[PrescriberEntityID] [int] NULL,
	[PrescriberName] [varchar](128) NULL,
	[PrescriberMCNZNumber] [varchar](255) NULL,
	[PCTOncologyPatientGroupingID] [int] NULL,
	[PCTOncologyPatientGrouping_Code] [int] NULL,
	[PCTOncologyPatientGrouping_Description] [varchar](100) NULL,
	[PCTPrescription_PrescriptionFormNumber] [varchar](9) NULL,
	[PCTPrescription_SpecialAuthorityNumber] [varchar](10) NULL,
	[PCTPrescription_SpecialistEndorserEntityID] [int] NULL,
	[PCTPrescription_SpecialistEndorserName] [varchar](128) NULL,
	[PCTPrescription_SpecialistEndorserMCNZNumber] [varchar](255) NULL,
	[PCTPrescription_EndorsementDate] [datetime] NULL,
	[FullWastage] [bit] NULL,
	[PatientEntityID] [int] NULL,
	[PatientName] [varchar](128) NULL,
	[PatientNHINumber] [varchar](255) NULL,
	[PCTPatient_PCTPatientID] [int] NULL,
	[PCTPatient_HUHCNo] [varchar](10) NULL,
	[PCTPatient_HUHCExpiry] [datetime] NULL,
	[PCTPatient_CSC] [bit] NULL,
	[PCTPatient_CSCExpiry] [datetime] NULL,
	[PCTPatient_PermResHokianga] [bit] NULL,
	[PCTPatient_PHORegistered] [bit] NULL,
	[RequestID_Dispensing] [int] NULL,
	[UniqueTransactionNumber] [int] NULL,
	[PrescriptionSuffix] [varchar](2) NULL,
	[OnHold] [bit] NULL,
	[Modified] [bit] NULL,
	[Resubmission] [bit] NULL,
	[Credit] [bit] NULL,
	[ErrorResubmit] [bit] NULL,
	[ErrorCredit] [bit] NULL,
	[Removed] [bit] NULL,
	[RemovedSubmitted] [bit] NULL
	) 
GO


