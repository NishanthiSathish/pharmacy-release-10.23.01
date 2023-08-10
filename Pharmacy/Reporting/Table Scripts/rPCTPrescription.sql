-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added rPCTPrescription structure
-- =======================================================================================================

IF OBJECT_ID('rPCTPrescription') IS NOT NULL
	DROP TABLE rPCTPrescription
GO

CREATE TABLE rPCTPrescription (
	[PCTPrescriptionID] [int] NOT NULL,
	[RequestID_Prescription] [int] NULL,
	[PrescriberEntityID] [int] NOT NULL,
	[PCTOncologyPatientGroupingID] [int] NOT NULL,
	[PrescriptionFormNumber] [varchar](9) NOT NULL,
	[SpecialAuthorityNumber] [varchar](10) NULL,
	[SpecialistEndorserEntityID] [int] NULL,
	[EndorsementDate] [datetime] NULL,
	[FullWastage] [bit] NOT NULL
	) 
GO


