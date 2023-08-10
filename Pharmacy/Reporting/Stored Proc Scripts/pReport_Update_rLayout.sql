SET ANSI_NULLS ON
GO

IF OBJECT_ID('pReport_Update_rLayout') IS NOT NULL
	DROP PROCEDURE pReport_Update_rLayout
GO


CREATE PROCEDURE pReport_Update_rLayout

AS

-- CHANGE LOG
-- ==========
-- 29Apr09 TH F0052134 replaced sys with icwsys


DECLARE @TEXT 			VARCHAR (8000)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rProduct'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rLayout

SET @TEXT = 

	'INSERT INTO rLayout (
		WLayoutID, 
		LocationID_Site, 
		PatientsPerSheet, 
		Layout, 
		LineText, 
		IngLineText, 
		Prescription, 
		name, 
		WManufacturingStatusID, 
		EntityID_Drafted, 
		EntityID_Approved, 
		DateDrafted, 
		DateApproved, 
		VersionNumber)

	SELECT 	
		WLayoutID, 
		LocationID_Site, 
		PatientsPerSheet, 
		Layout, 
		LineText, 
		IngLineText, 
		Prescription, 
		name, 
		WManufacturingStatusID, 
		EntityID_Drafted, 
		EntityID_Approved, 
		DateDrafted, 
		DateApproved, 
		VersionNumber
	FROM ' + @LiveDB + '.icwsys.wLayout'

EXECUTE (@TEXT)

PRINT ''
