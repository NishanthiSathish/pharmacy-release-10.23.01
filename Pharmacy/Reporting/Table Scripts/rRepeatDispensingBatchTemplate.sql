-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added rRepeatDispensingBatchTemplate structure
-- =======================================================================================================

IF OBJECT_ID('rRepeatDispensingBatchTemplate') IS NOT NULL
	DROP TABLE rRepeatDispensingBatchTemplate
GO

CREATE TABLE rRepeatDispensingBatchTemplate(
	[RepeatDispensingBatchTemplateID] [int] NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[LocationID] [int] NULL,
	[InPatient] [bit] NOT NULL,
	[OutPatient] [bit] NOT NULL,
	[Discharge] [bit] NOT NULL,
	[Leave] [bit] NOT NULL,
	[SelectPatientsByDefault] [bit] NOT NULL,
	[BagLabels] [int] NOT NULL,
	[JVM] [bit] NOT NULL,
	[JVMDefaultStartTomorrow] [bit] NULL,
	[JVMDuration] [int] NULL,
	[JVMBreakfast] [bit] NULL,
	[JVMLunch] [bit] NULL,
	[JVMTea] [bit] NULL,
	[JVMNight] [bit] NULL,
	[JVMIncludeManual] [bit] NULL,
	[JVMSortByAdminSlot] [bit] NULL,
	[InUse] [bit] NOT NULL) 

GO
