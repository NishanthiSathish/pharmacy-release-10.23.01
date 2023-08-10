-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added rPCTClaimFile structure
-- =======================================================================================================

IF OBJECT_ID('rPCTClaimFile') IS NOT NULL
	DROP TABLE rPCTClaimFile
GO

CREATE TABLE rPCTClaimFile (
	[PCTClaimFileID] [int] NOT NULL,
	[DataSpecificationRelease] [char](3) NULL,
	[SLANumber] [varchar](7) NULL,
	[Generated] [datetime] NULL,
	[System] [varchar](10) NULL,
	[SystemVersion] [varchar](6) NULL,
	[ScheduleDate] [datetime] NULL,
	[ClaimDate] [datetime] NOT NULL,
	[FileID] [int] NULL,
	[SiteID] [int] NULL
	) 
GO


