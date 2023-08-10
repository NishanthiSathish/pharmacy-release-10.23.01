-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added rRepeatDispensingPrescriptionLinkDispensing structure
-- =======================================================================================================

IF OBJECT_ID('rRepeatDispensingPrescriptionLinkDispensing') IS NOT NULL
	DROP TABLE rRepeatDispensingPrescriptionLinkDispensing
GO

CREATE TABLE rRepeatDispensingPrescriptionLinkDispensing(
	[PrescriptionID] [int] NOT NULL,
	[DispensingID] [int] NOT NULL,
	[InUse] [bit] NULL,
	[Quantity] [float] NOT NULL,
	[RepeatDispensingPrescriptionLinkDispensingID] [int] NOT NULL,
	[SessionLock] [int] NULL,
	[JVM] [bit] NOT NULL)

GO
