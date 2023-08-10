-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added rRepeatDispensingBatchLinkEntity structure
-- =======================================================================================================

IF OBJECT_ID('rRepeatDispensingBatchLinkEntity') IS NOT NULL
	DROP TABLE rRepeatDispensingBatchLinkEntity
GO

CREATE TABLE rRepeatDispensingBatchLinkEntity(
	[BatchID] [int] NOT NULL,
	[EntityID] [int] NOT NULL
) 

GO
