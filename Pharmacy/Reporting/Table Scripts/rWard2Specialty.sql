IF OBJECT_ID('rWard2Specialty') IS NOT NULL
	DROP TABLE rWard2Specialty
GO

CREATE TABLE rWard2Specialty (
		[WardCode]  varchar (20) PRIMARY KEY NOT NULL , 
		[SpecialtyCode] varchar (5) NOT NULL 
	)
GO

-- =======================================================================================================
-- Author:	Aidan Kent (AK)
-- Create date: 04nov08
-- Ref:		F0036909
-- Description:	Create index for joins used by Cognos reporting
-- =======================================================================================================

IF exists (SELECT * from sysindexes where name = N'IX_rWard2Specialty_SpecialtyCode' and id = object_id(N'[rWard2Specialty]'))
DROP INDEX [rWard2Specialty].[IX_rWard2Specialty_SpecialtyCode]
GO
CREATE INDEX [IX_rWard2Specialty_SpecialtyCode] ON [rWard2Specialty]([SpecialtyCode]) ON [PRIMARY]
GO
