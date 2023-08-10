IF OBJECT_ID('rDivision') IS NOT NULL
	DROP TABLE rDivision
GO

CREATE TABLE rDivision (
	[DivisionCode] varchar (20) PRIMARY KEY NOT NULL ,
	[Description] varchar (500) NOT NULL
) 
GO
