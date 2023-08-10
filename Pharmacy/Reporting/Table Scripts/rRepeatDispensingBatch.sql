-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added rRepeatDispensingBatch structure
-- =======================================================================================================

IF OBJECT_ID('rRepeatDispensingBatch') IS NOT NULL
	DROP TABLE rRepeatDispensingBatch
GO

CREATE TABLE rRepeatDispensingBatch(
	[RepeatDispensingBatchID] [int] NOT NULL,
	[BatchDescription] [varchar](8000) NOT NULL,
	[StatusID] [int] NOT NULL,
	[Factor] [int] NOT NULL,
	[RepeatDispensingBatchTemplateID] [int] NULL,
	[StartDate] [datetime] NULL,
	[StartSlot] [tinyint] NULL,
	[TotalSlots] [int] NULL,
	[BagLabelsPerPatient] [int] NULL,
	[SortByDate] [bit] NULL,
	[LocationID] [int] NULL,
	[Breakfast] [bit] NULL,
	[Lunch] [bit] NULL,
	[Tea] [bit] NULL,
	[Night] [bit] NULL,
	[IncludeManual] [bit] NULL
	)
GO