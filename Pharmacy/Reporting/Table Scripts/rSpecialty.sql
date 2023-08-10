-- 01Feb08 JKu Changed table structure. We now import our specialty lookup data from the SpecialtyLinks spreadsheet as
--			      the data on the live ICW database is very unreliable and incomplete.

IF OBJECT_ID('rSpecialty') IS NOT NULL
	DROP TABLE rSpecialty
GO

CREATE TABLE rSpecialty (
	SpecialtyCode VARCHAR (25) PRIMARY KEY NOT NULL ,
	[Description] varchar (250) ,
	DirectorateCode varchar (20) NULL ,
	DivisionCode varchar (20) NULL ,
	CostCentre varchar (125) NULL
) 
GO

-- =======================================================================================================
-- Author:	Aidan Kent (AK)
-- Create date: 04nov08
-- Ref:		F0036909
-- Description:	Create index for joins used by Cognos reporting
-- =======================================================================================================

IF exists (SELECT * from sysindexes where name = N'IX_rSpecialty_DirectorateCode' and id = object_id(N'[rSpecialty]'))
DROP INDEX [rSpecialty].[IX_rSpecialty_DirectorateCode]
GO
CREATE INDEX [IX_rSpecialty_DirectorateCode] ON [rSpecialty]([DirectorateCode]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rSpecialty_DivisionCode' and id = object_id(N'[rSpecialty]'))
DROP INDEX [rSpecialty].[IX_rSpecialty_DivisionCode]
GO
CREATE INDEX [IX_rSpecialty_DivisionCode] ON [rSpecialty]([DivisionCode]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rSpecialty_DivisionCode' and id = object_id(N'[rSpecialty]'))
DROP INDEX [rSpecialty].[IX_rSpecialty_DivisionCode]
GO
CREATE INDEX [IX_rSpecialty_DivisionCode] ON [rSpecialty]([DivisionCode]) ON [PRIMARY]
GO
