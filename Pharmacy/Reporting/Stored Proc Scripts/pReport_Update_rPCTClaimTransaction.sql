-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rPCTClaimTransaction') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPCTClaimTransaction
GO

CREATE PROCEDURE pReport_Update_rPCTClaimTransaction

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @TEXT2 varchar(max)
DECLARE @TEXT3 varchar(max)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rPCTClaimTransaction'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rPCTClaimTransaction


SET @TEXT = '
	INSERT INTO rPCTClaimTransaction (
		[PCTClaimTransactionID],
		[PCTClaimFileID],
		[PCTClaimFile_DataSpecificationRelease],
		[PCTClaimFile_SLANumber],
		[PCTClaimFile_Generated],
		[PCTClaimFile_System],
		[PCTClaimFile_SystemVersion],
		[PCTClaimFile_ScheduleDate],
		[PCTClaimFile_ClaimDate],
		[PCTClaimFile_FileID],
		[PCTClaimFile_SiteID],
		[SiteNumber],
		[SitE_Description],
		[Site_Details],
		[Category],
		[ComponentNumber],
		[TotalComponentNumber],
		[PrescriberID],
		[HealthProfessionalGroupCode],
		[SpecialistID],
		[EndorsementDate],
		[PrescriberFlag],
		[PCTOncologyPatientGrouping],
		[NHI],
		[PCTPatientCategory],
		[CSCorPHOStatusFlag],
		[HUHCStatusFlag],
		[SpecialAuthorityNumber],
		[Dose],
		[DailyDose],
		[PrescriptionFlag],
		[DoseFlag],
		[PrescriptionID],
		[ServiceDate],
		[ClaimCode],
		[PCTProduct_BrandCode],
		[PCTProduct_BrandName],
		[PCTProduct_FormulationName],
		[PCTProduct_ChemicalName],
		[PCTProduct_Quantity],
		[PCTProduct_Multiple],
		[PCTProduct_Specified],
		[PCTProduct_Subsidy],
		[PCTProduct_Alternate],
		[PCTProduct_Price],
		[PCTProduct_CBS],
		[PCTProduct_OP],
		[PCTProduct_SpecialType],
		[PCTProduct_SpecialEndorsementType],
		[PCTProduct_DrugFileDate],
		[PCTProduct_Units],
		[PCTProduct_PCTProductID],
		[PCTProduct_PCTMasterProductID],
		[QuantityClaimed],
		[PackUnitOfMeasure],
		[ClaimAmount],
		[CBSSubsidy],
		[CBSPacksize],
		[Funder],
		[FormNumber],
		[ParentID],
		[SupersededDate],
		[SupersededByEntityID],
		[SupersededByName],
		[ScheduleDate],
		[RequestID_Prescription],
		[PCTPrescriptionID],
		[PrescriberEntityID],
		[PrescriberName],
		[PrescriberMCNZNumber],
		[PCTOncologyPatientGroupingID],
		[PCTOncologyPatientGrouping_Code],
		[PCTOncologyPatientGrouping_Description],
		[PCTPrescription_PrescriptionFormNumber],
		[PCTPrescription_SpecialAuthorityNumber],
		[PCTPrescription_SpecialistEndorserEntityID],
		[PCTPrescription_SpecialistEndorserName],
		[PCTPrescription_SpecialistEndorserMCNZNumber],
		[PCTPrescription_EndorsementDate],
		[FullWastage],
		[PatientEntityID],
		[PatientName],
		[PatientNHINumber],
		[PCTPatient_PCTPatientID],
		[PCTPatient_HUHCNo],
		[PCTPatient_HUHCExpiry],
		[PCTPatient_CSC],
		[PCTPatient_CSCExpiry],
		[PCTPatient_PermResHokianga],
		[PCTPatient_PHORegistered],
		[RequestID_Dispensing],
		[UniqueTransactionNumber],
		[PrescriptionSuffix],
		[OnHold],
		[Modified],
		[Resubmission],
		[Credit],
		[ErrorResubmit],
		[ErrorCredit],
		[Removed],
		[RemovedSubmitted])
	'
	
SET @TEXT2 = '
SELECT
		ct.PCTClaimTransactionID as PCTClaimTransactionID
	,   ct.PCTClaimFileID as PCTClaimFileID
	,   cf.DataSpecificationRelease as PCTClaimFile_DataSpecificationRelease
	,   cf.SLANumber as PCTClaimFile_SLANumber
	,   cf.Generated as PCTClaimFile_Generated
	,   cf.System as PCTClaimFile_System
	,   cf.SystemVersion as PCTClaimFile_SystemVersion
	,   cf.ScheduleDate as PCTClaimFile_ScheduleDate
	,   cf.ClaimDate as PCTClaimFile_ClaimDate
	,   cf.FileID as PCTClaimFile_FileID
	,   cf.SiteID as PCTClaimFile_SiteID
	,   s.SiteNumber as SiteNumber
	,   l.Description as SitE_Description
	,   l.Detail as Site_Details
	,   ct.Category as Category
	,   ct.ComponentNumber as ComponentNumber
	,   ct.TotalComponentNumber as TotalComponentNumber
	,   ct.PrescriberID as PrescriberID
	,   ct.HealthProfessionalGroupCode as HealthProfessionalGroupCode
	,   ct.SpecialistID as SpecialistID
	,   ct.EndorsementDate as EndorsementDate
	,   ct.PrescriberFlag as PrescriberFlag
	,   ct.PCTOncologyPatientGrouping as PCTOncologyPatientGrouping
	,   ct.NHI as NHI
	,   ct.PCTPatientCategory as PCTPatientCategory
	,   ct.CSCorPHOStatusFlag as CSCorPHOStatusFlag
	,   ct.HUHCStatusFlag as HUHCStatusFlag
	,   ct.SpecialAuthorityNumber as SpecialAuthorityNumber
	,   ct.Dose as Dose
	,   ct.DailyDose as DailyDose
	,   ct.PrescriptionFlag as PrescriptionFlag
	,   ct.DoseFlag as DoseFlag
	,   ct.PrescriptionID as PrescriptionID
	,   ct.ServiceDate as ServiceDate
	,   ct.ClaimCode as ClaimCode
	,   pr.BrandCode as PCTProduct_BrandCode
	,   pr.BrandName as PCTProduct_BrandName
	,   pr.FormulationName as PCTProduct_FormulationName
	,   pr.ChemicalName as PCTProduct_ChemicalName
	,   pr.Quantity as PCTProduct_Quantity
	,   pr.Multiple as PCTProduct_Multiple
	,   pr.Specified as PCTProduct_Specified
	,   pr.Subsidy as PCTProduct_Subsidy
	,   pr.Alternate as PCTProduct_Alternate
	,   pr.Price as PCTProduct_Price
	,   pr.CBS as PCTProduct_CBS
	,   pr.OP as PCTProduct_OP
	,   pr.SpecialType as PCTProduct_SpecialType
	,   pr.SpecialEndorsementType as PCTProduct_SpecialEndorsementType
	,   pr.DrugFileDate as PCTProduct_DrugFileDate
	,   pr.Units as PCTProduct_Units
	,   pr.PCTProductID as PCTProduct_PCTProductID
	,   pr.PCTMasterProductID as PCTProduct_PCTMasterProductID
	,   ct.QuantityClaimed as QuantityClaimed
	,   ct.PackUnitOfMeasure as PackUnitOfMeasure
	,   ct.ClaimAmount as ClaimAmount
	,   ct.CBSSubsidy as CBSSubsidy
	,   ct.CBSPacksize as CBSPacksize
	,   ct.Funder as Funder
	,   ct.FormNumber as FormNumber
	,   ct.ParentID as ParentID
	,   ct.SupersededDate as SupersededDate
	,   ct.SupersededByEntityID as SupersededByEntityID
	,   sse.Description as SupersededByName
	,   ct.ScheduleDate as ScheduleDate
	,   ct.RequestID_Prescription as RequestID_Prescription
	,   rx.PCTPrescriptionID as PCTPrescriptionID
	,   rx.PrescriberEntityID as PrescriberEntityID
	,   pre.Description as PrescriberName
	,   prea.Alias as PrescriberMCNZNumber
	,   rx.PCTOncologyPatientGroupingID as PCTOncologyPatientGroupingID
	,   opg.Code as PCTOncologyPatientGrouping_Code
	,   opg.Description as PCTOncologyPatientGrouping_Description
	,   rx.PrescriptionFormNumber as PCTPrescription_PrescriptionFormNumber
	,   rx.SpecialAuthorityNumber as PCTPrescription_SpecialAuthorityNumber
	,   rx.SpecialistEndorserEntityID as PCTPrescription_SpecialistEndorserEntityID
	,   see.Description as PCTPrescription_SpecialistEndorserName
	,   seea.Alias as PCTPrescription_SpecialistEndorserMCNZNumber
	,   rx.EndorsementDate as PCTPrescription_EndorsementDate
	,   rx.FullWastage as FullWastage
	,   ep.EntityID as PatientEntityID
	,   pe.Description as PatientName
	,   pea.Alias as PatientNHINumber
	,   p.PCTPatientID as PCTPatient_PCTPatientID
	,   p.HUHCNo as PCTPatient_HUHCNo
	,   p.HUHCExpiry as PCTPatient_HUHCExpiry
	,   p.CSC as PCTPatient_CSC
	,   p.CSCExpiry as PCTPatient_CSCExpiry
	,   p.PermResHokianga as PCTPatient_PermResHokianga
	,   p.PHORegistered as PCTPatient_PHORegistered
	,   ct.RequestID_Dispensing as RequestID_Dispensing
	,   ct.UniqueTransactionNumber as UniqueTransactionNumber
	,   ct.PrescriptionSuffix as PrescriptionSuffix
	,   ct.OnHold as OnHold
	,   ct.Modified as Modified
	,   ct.Resubmission as Resubmission
	,   ct.Credit as Credit
	,   ct.ErrorResubmit as ErrorResubmit
	,   ct.ErrorCredit as ErrorCredit
	,   ct.Removed as Removed
	,   ct.RemovedSubmitted as RemovedSubmitted
'
SET @TEXT3 = '

FROM
	' + @LiveDB + '.icwsys.PCTClaimTransaction ct
	LEFT JOIN ' + @LiveDB + '.icwsys.PCTClaimFile cf on ct.PCTClaimFileID = cf.PCTClaimFileID
	LEFT JOIN ' + @LiveDB + '.icwsys.[Site] s on cf.SiteID = s.LocationID
	LEFT JOIN ' + @LiveDB + '.icwsys.Location l on cf.SiteID = l.LocationID
	LEFT JOIN ' + @LiveDB + '.icwsys.PCTProduct pr on ct.ClaimCode = pr.PharmaCode
	LEFT JOIN ' + @LiveDB + '.icwsys.Entity sse on ct.SupersededByEntityID = sse.EntityID
	LEFT JOIN ' + @LiveDB + '.icwsys.PCTPrescription rx on ct.RequestID_Prescription = rx.RequestID_Prescription
	LEFT JOIN ' + @LiveDB + '.icwsys.Entity pre on rx.PrescriberEntityID = pre.EntityID
	LEFT JOIN ' + @LiveDB + '.icwsys.AliasGroup prag on prag.[Description] = ''MCNZNumber''
	LEFT JOIN ' + @LiveDB + '.icwsys.EntityAlias prea on rx.PrescriberEntityID = prea.EntityID and prag.AliasGroupID = prea.AliasGroupID and prea.[Default] = 1
	LEFT JOIN ' + @LiveDB + '.icwsys.PCTOncologyPatientGrouping opg on opg.PCTOncologyPatientGroupingID = rx.PCTOncologyPatientGroupingID
	LEFT JOIN ' + @LiveDB + '.icwsys.Entity see on rx.SpecialistEndorserEntityID = see.EntityID
	LEFT JOIN ' + @LiveDB + '.icwsys.AliasGroup seag on seag.[Description] = ''MCNZNumber''
	LEFT JOIN ' + @LiveDB + '.icwsys.EntityAlias seea on rx.SpecialistEndorserEntityID = seea.EntityID and seea.AliasGroupID = seag.AliasGroupID
	LEFT JOIN ' + @LiveDB + '.icwsys.EpisodeOrder eo on ct.RequestID_Prescription = eo.RequestID
	LEFT JOIN ' + @LiveDB + '.icwsys.Episode ep on eo.EpisodeID = ep.EpisodeID
	LEFT JOIN ' + @LiveDB + '.icwsys.Entity pe on ep.EntityID = pe.EntityID
	LEFT JOIN ' + @LiveDB + '.icwsys.AliasGroup peag on peag.[Description] = ''NHINumber''
	LEFT JOIN ' + @LiveDB + '.icwsys.EntityAlias pea on pea.AliasGroupID = peag.AliasGroupID and pea.EntityID = ep.EntityID
	LEFT JOIN ' + @LiveDB + '.icwsys.PCTPatient p on p.EntityID = ep.EntityID

'

EXECUTE (@TEXT + @TEXT2 + @TEXT3)

PRINT ''
