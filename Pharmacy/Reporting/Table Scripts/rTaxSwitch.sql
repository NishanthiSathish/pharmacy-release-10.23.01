IF OBJECT_ID('tempDB..#rTaxSwitch') IS NOT NULL
	DROP TABLE #rTaxSwitch

IF OBJECT_ID('rTaxSwitch') IS NOT NULL
	BEGIN
		SELECT * INTO #rTaxSwitch FROM rTaxSwitch
		DROP TABLE rTaxSwitch
	END
GO

CREATE TABLE dbo.rTaxSwitch (
	TaxInclusive INT NOT NULL 
)
GO

IF OBJECT_ID('tempDB..#rTaxSwitch') IS NOT NULL
	BEGIN
		INSERT INTO rTaxSwitch (TaxInclusive) (SELECT TaxInclusive FROM #rTaxSwitch)
	END
ELSE
	BEGIN
		INSERT INTO rTaxSwitch (TaxInclusive) VALUES (0)
	END
GO
