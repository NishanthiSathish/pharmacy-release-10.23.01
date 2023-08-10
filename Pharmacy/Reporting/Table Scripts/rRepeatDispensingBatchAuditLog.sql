-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added rRepeatDispensingBatchAuditLog structure
-- =======================================================================================================

IF OBJECT_ID('rRepeatDispensingBatchAuditLog') IS NOT NULL
	DROP TABLE rRepeatDispensingBatchAuditLog
GO

CREATE TABLE rRepeatDispensingBatchAuditLog(
	[RepeatDispensingBatchAuditLogID] [int] NOT NULL,
	[RepeatDispensingBatchID] [int] NOT NULL,
	[StatusID] [int] NOT NULL,
	[DateChanged] [datetime] NOT NULL,
	[EntityID] [int] NOT NULL
	)

GO
