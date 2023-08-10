-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added rPCTOncologyPatientGrouping structure
-- =======================================================================================================

IF OBJECT_ID('rPCTOncologyPatientGrouping') IS NOT NULL
	DROP TABLE rPCTOncologyPatientGrouping
GO

CREATE TABLE rPCTOncologyPatientGrouping (
	[PCTOncologyPatientGroupingID] [int] NOT NULL,
	[Code] [int] NOT NULL,
	[Description] [varchar](100) NOT NULL
	) 
GO


