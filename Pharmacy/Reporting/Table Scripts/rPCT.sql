IF OBJECT_ID('rPCT') IS NOT NULL
	DROP TABLE rPCT 
GO

CREATE TABLE rPCT (
	[PCTCode] varchar (20) PRIMARY KEY NOT NULL ,
	[Description] varchar (500) NOT NULL
) 
GO

