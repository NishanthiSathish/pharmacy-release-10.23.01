-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added rPCTPatient structure
-- =======================================================================================================

IF OBJECT_ID('rPCTPatient') IS NOT NULL
	DROP TABLE rPCTPatient
GO

CREATE TABLE rPCTPatient (
	[PCTPatientID] [int] NOT NULL,
	[EntityID] [int] NOT NULL,
	[HUHCNo] [varchar](10) NULL,
	[HUHCExpiry] [datetime] NULL,
	[CSC] [bit] NOT NULL,
	[CSCExpiry] [datetime] NULL,
	[PermResHokianga] [bit] NOT NULL,
	[PHORegistered] [bit] NOT NULL
	) 
GO


