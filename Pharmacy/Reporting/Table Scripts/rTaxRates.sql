IF OBJECT_ID('rTaxRates') IS NOT NULL
	DROP TABLE rTaxRates
GO

CREATE TABLE dbo.rTaxRates (
	TaxCode VARCHAR (1) PRIMARY KEY NOT NULL ,
	TaxRate FLOAT NULL 
)



