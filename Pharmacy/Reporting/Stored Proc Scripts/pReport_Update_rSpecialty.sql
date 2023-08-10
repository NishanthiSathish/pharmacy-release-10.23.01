IF OBJECT_ID('pReport_Update_rSpecialty') IS NOT NULL
	DROP PROCEDURE pReport_Update_rSpecialty
GO

CREATE PROCEDURE pReport_Update_rSpecialty
AS

-- CHANGE LOG
-- ==========
-- 01Feb08 JKu Completely re-written SP. We now pull in the specialty details from a spreadsheet. 
-- This is a more reliable method. The SP will append specialty codes found in the rTranslog table 
-- that are not found in the spreadsheet. This is a unlikely event. NB: If the import fails, we
-- back out so no harm done.

-- 24Apr08 JKu Replace 'CREATE TABLE .. ' statement with 'SELECT INTO ..' to avoid collation issues.
-- 29Nov16 XN  Removed csv file for hosted 147104

DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rDirectorate'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

-- Just in case.
IF OBJECT_ID('tempDB..#Specialty') IS NOT NULL
	DROP TABLE #Specialty

IF OBJECT_ID('tempDB..#DistinctSpecialty') IS NOT NULL
	DROP TABLE #DistinctSpecialty

IF OBJECT_ID('tempDB..#TranslogSpecialty') IS NOT NULL
	DROP TABLE #TranslogSpecialty

-- 24Apr08 JKU Replaced
--CREATE TABLE #Specialty (
--	SpecialtyCode VARCHAR (20) NULL
--,	[Description] VARCHAR (250) NULL
--,	DirectorateCode VARCHAR (20) NULL
--,	DivisionCode VARCHAR (20) NULL
--,	CostCentre VARCHAR (50) NULL
--)
SELECT * INTO #Specialty FROM rSpecialty WHERE 1=0

DECLARE @CmdText VARCHAR (2500)
SET @CmdText =
'INSERT INTO #Specialty 
	SELECT SpecialityCode as SpecialtyCode,
		   [Description],
		   DirectorateCode,
		   DivisionCode,
		   CostCentre
	FROM ' + @LiveDB + '.icwsys.WReportingSpeciality'

EXECUTE (@CmdText)

-- Return if no records found in spreadsheet.
IF (SELECT COUNT(SpecialtyCode) FROM #Specialty) = 0
	BEGIN
		PRINT 'SPECIALTY LINKS ARE EMPTY!'
		RETURN
	END

-- Get rid of blanks
DELETE FROM #Specialty WHERE ISNULL(SpecialtyCode, '') = ''

-- Create a table of distinct specialty codes. Only the first instance of other fields will be taken.
SELECT 
	SpecialtyCode 
,	MIN([Description]) [Description]
,	MIN(DirectorateCode) DirectorateCode
,	MIN(DivisionCode) DivisionCode
,	MIN(CostCentre) CostCentre
INTO #DistinctSpecialty 
FROM #Specialty 
GROUP BY SpecialtyCode 

TRUNCATE TABLE rSpecialty

INSERT INTO rSpecialty (
	SpecialtyCode, 
	[Description], 
	DirectorateCode, 
	DivisionCode, 
	CostCentre
)
(SELECT  
	SpecialtyCode, 
	[Description], 
	DirectorateCode, 
	DivisionCode, 
	CostCentre
FROM #DistinctSpecialty)

-- Now we append the specialty codes that are found in the wTranslog but not in the spreadsheet
SELECT DISTINCT Specialty SpecialtyCode
INTO #TranslogSpecialty 
FROM rTranslog 
WHERE ISNULL(Specialty, '') <> ''

INSERT INTO rSpecialty (
	SpecialtyCode
)
(SELECT A.SpecialtyCode 
FROM #TranslogSpecialty A
LEFT JOIN #DistinctSpecialty B ON A.SpecialtyCode = B.SpecialtyCode
WHERE B.SpecialtyCode IS NULL)
