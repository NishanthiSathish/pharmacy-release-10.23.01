IF OBJECT_ID('rDirectorate') IS NOT NULL
	DROP TABLE rDirectorate
GO

CREATE TABLE rDirectorate (
	[DirectorateCode] varchar (20) PRIMARY KEY NOT NULL ,
	[Description] varchar (500) NOT NULL
) 
GO

