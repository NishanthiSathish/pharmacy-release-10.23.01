--29Apr09 TH F0052134 replaced sys with icwsys

IF OBJECT_ID('pReport_Update_rTaxRates') IS NOT NULL
	DROP PROCEDURE pReport_Update_rTaxRates 
GO

CREATE PROCEDURE pReport_Update_rTaxRates 

AS

DECLARE @LiveDB 	VARCHAR (max)
DECLARE @TEXT		VARCHAR (1024)
DECLARE @CURRENT_MONTH	VARCHAR(6)

PRINT 'Running pReport_Update_rTaxRates'

SET @LiveDB 	= (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rTaxRates

SET @TEXT = '
INSERT INTO rTaxRates (
	TaxCode,
	TaxRate )


SELECT  
	SUBSTRING([Key], (CHARINDEX(''('', [Key]) + 1), 1) TaxCode, 	
	MIN(CONVERT(FLOAT, SUBSTRING([Value], 2, (CHARINDEX(''"'', [Value] , 2) - 2)))) TaxRate
FROM
	' + @LiveDB + '.icwsys.wConfiguration	

WHERE Category LIKE ''D|Workingdefaults'' AND SUBSTRING([Key],1,3) = ''VAT''

GROUP BY [Key]'

EXECUTE (@TEXT)

PRINT ''

