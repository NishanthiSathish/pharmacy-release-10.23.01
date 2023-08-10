SET ANSI_NULLS ON
GO

IF OBJECT_ID('pReport_Update_rFormula') IS NOT NULL
	DROP PROCEDURE pReport_Update_rFormula
GO


CREATE PROCEDURE pReport_Update_rFormula

AS

-- CHANGE LOG
-- ==========
-- 29Apr09 TH F0052134 replaced sys with icwsys


DECLARE @TEXT 			VARCHAR (8000)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rProduct'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rFormula

SET @TEXT = 

	'INSERT INTO rFormula (
		WFormulaID, 
		LocationID_Site, 
		Authorised2, 
		Layout2, 
		NSVcode, 
		code1, 
		code2, 
		code3, 
		code4, 
		code5, 
		code6, 
		code7, 
		code8, 
		code9, 
		code10, 
		code11, 
		code12, 
		code13, 
		code14, 
		code15, 
		qty1, 
		qty2, 
		qty3, 
		qty4, 
		qty5, 
		qty6, 
		qty7, 
		qty8, 
		qty9, 
		qty10, 
		qty11, 
		qty12, 
		qty13,
		qty14,
		qty15,
		type1,
		type2,
		type3,
		type4,
		type5,
		type6,
		type7,
		type8,
		type9,
		type10,
		type11,
		type12,
		type13,
		type14,
		type15,
		Method,
		TotalQty,
		NumofLabels,
		Label,
		ExtraLabels,
		DosingUnits,
		d1,
		d2,
		d3,
		d4,
		d5,
		d6,
		d7,
		d8,
		d9,
		d10,
		d11,
		d12,
		d13,
		d14,
		d15,
		Authorised,
		Authorised_Date,
		Layout,
		WManufacturingStatusID,
		EntityID_Drafted,
		EntityID_Approved,
		DateDrafted,
		DateApproved,
		VersionNumber)

	SELECT 	
		WFormulaID, 
		LocationID_Site, 
		Authorised2, 
		Layout2, 
		NSVcode, 
		code1, 
		code2, 
		code3, 
		code4, 
		code5, 
		code6, 
		code7, 
		code8, 
		code9, 
		code10, 
		code11, 
		code12, 
		code13, 
		code14, 
		code15, 
		qty1, 
		qty2, 
		qty3, 
		qty4, 
		qty5, 
		qty6, 
		qty7, 
		qty8, 
		qty9, 
		qty10, 
		qty11, 
		qty12, 
		qty13,
		qty14,
		qty15,
		type1,
		type2,
		type3,
		type4,
		type5,
		type6,
		type7,
		type8,
		type9,
		type10,
		type11,
		type12,
		type13,
		type14,
		type15,
		Method,
		TotalQty,
		NumofLabels,
		Label,
		ExtraLabels,
		DosingUnits,
		d1,
		d2,
		d3,
		d4,
		d5,
		d6,
		d7,
		d8,
		d9,
		d10,
		d11,
		d12,
		d13,
		d14,
		d15,
		Authorised,
		Authorised_Date,
		Layout,
		WManufacturingStatusID,
		EntityID_Drafted,
		EntityID_Approved,
		DateDrafted,
		DateApproved,
		VersionNumber
	FROM ' + @LiveDB + '.icwsys.wFormula'

EXECUTE (@TEXT)

PRINT ''
