IF OBJECT_ID('rPatients') IS NOT NULL
	DROP TABLE rPatients
GO

--Change Log
--27Jun08 JKu Change field size for NHSNumber from 10 to 255
--27Jun08 JKu Added new field CaseNumber
--08Oct09 PJC Added new HeathcareNumber for future catalog, NHS number kept for backward compatibility (F0064619)
--15Oct09 PJC F0066390 Added BoxNumber,DoorNumber,Building,Street,Town,LocalAuthority,District,PostCode,Province,Country

CREATE TABLE dbo.rPatients (
	PatID VARCHAR (10) PRIMARY KEY NOT NULL ,
	Title VARCHAR (128) NULL ,
	Initials VARCHAR (10) NULL ,
	Forename VARCHAR (128) NULL ,
	Surname VARCHAR (128) NULL ,
	DOB DATETIME NULL ,
	CaseNumber VARCHAR (255) NULL ,
	NHSNumber VARCHAR (255) NULL ,
	NHSNumberValid VARCHAR (4) NULL ,
	Sex VARCHAR (20) NULL,
	HealthCareNumber VARCHAR (255) NULL ,
	HealthCareNumberValid bit NULL,
	[BoxNumber] VARCHAR (30) NULL,
	[DoorNumber] VARCHAR (10) NULL,
	[Building] VARCHAR (50) NULL,
	[Street] VARCHAR (50) NULL,
	[Town] VARCHAR (50) NULL,
	[LocalAuthority] VARCHAR (50) NULL,
	[District] VARCHAR (50) NULL,
	[PostCode] VARCHAR (15) NULL,
	[Province] VARCHAR (50) NULL,
	[Country] VARCHAR (50) NULL
) 
GO


