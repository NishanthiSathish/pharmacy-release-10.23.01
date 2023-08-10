-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added rRepeatDispensingPatient structure
-- =======================================================================================================

IF OBJECT_ID('rRepeatDispensingPatient') IS NOT NULL
	DROP TABLE rRepeatDispensingPatient
GO

CREATE TABLE rRepeatDispensingPatient(
	[RepeatDispensingPatientID] [int] NOT NULL,
	[EntityID] [int] NOT NULL,
	[SupplyDays] [int] NULL,
	[ADM] [bit] NULL,
	[InUse] [bit] NOT NULL,
	[SupplyPatternID] [int] NULL,
	[AdditionalInformation] [varchar](30) NULL,
	[RepeatDispensingBatchTemplateID] [int] NULL)

GO
