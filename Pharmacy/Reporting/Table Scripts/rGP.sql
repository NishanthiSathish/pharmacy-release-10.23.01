IF OBJECT_ID('rGP') IS NOT NULL
	DROP TABLE rGP
GO

CREATE TABLE rGP (
	
	EntityID INT PRIMARY KEY NOT NULL ,
	GPName VARCHAR (250) NULL ,
	GPClassificationID INT NULL ,
	RegNumber VARCHAR (20) NULL ,
	Contract VARCHAR (1) NULL ,
	Obstetric INT NULL ,
	JobShare INT NULL ,
	Trainer INT NULL ,
	BoxNumber VARCHAR (30) NULL ,
	DoorNumber VARCHAR (10) NULL ,
	Building VARCHAR (50) NULL ,
	Street VARCHAR (50) NULL ,
	Town VARCHAR (50) NULL ,
	LocalAuthority VARCHAR (50) NULL ,
	District VARCHAR (50) NULL ,
	PostCode VARCHAR (15) NULL ,
	Province VARCHAR (50) NULL ,
	Country VARCHAR (50) NULL ,
	Notes VARCHAR (1024) NULL ,
	GPClassification_Description VARCHAR (50) NULL ,
	GPClassification_Detail VARCHAR (1024) NULL ,
	PCTCode VARCHAR (20) NULL

) 
GO

