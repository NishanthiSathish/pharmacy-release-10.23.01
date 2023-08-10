-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added rRepeatDispensingBatchStatus structure
-- =======================================================================================================

IF OBJECT_ID('rRepeatDispensingBatchStatus') IS NOT NULL
	DROP TABLE rRepeatDispensingBatchStatus
GO

CREATE TABLE rRepeatDispensingBatchStatus(
	[StatusID] [int] NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[Code] [char](1) NOT NULL)

GO

