-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		12Apr12
-- Ref:				31016
-- Description:		Added rRepeatDispensingSupplyPatterns structure
-- =======================================================================================================

IF OBJECT_ID('rRepeatDispensingSupplyPatterns') IS NOT NULL
	DROP TABLE rRepeatDispensingSupplyPatterns
GO

CREATE TABLE rRepeatDispensingSupplyPatterns(
	[SupplyPatternID] [int] NOT NULL,
	[Description] [varchar](255) NOT NULL,
	[Days] [int] NOT NULL,
	[IsDefault] [bit] NULL,
	[SplitDays] [int] NOT NULL,
	[Active] [bit] NOT NULL)

GO
