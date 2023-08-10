IF OBJECT_ID('pReport_Update_rWard2Specialty') IS NOT NULL
	DROP PROCEDURE pReport_Update_rWard2Specialty
GO

CREATE PROCEDURE pReport_Update_rWard2Specialty 
AS

-- CHANGE LOG
-- ==========
-- 01Feb08 JKu Completely re-written SP. 
-- 24Apr08 JKu Replaced 'CREATE TABLE ..' statement with 'SELECT INTO..' to avoid collation problems.
-- 09Oct08 AK Replaced fixed string 'Update Database' with 'XXXXX' for insert into rWard2Speciality so it fits in rTranLog
-- 29Nov16 XN  Removed csv file for hosted 147104

DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rWard2Specialty'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

-- Just in case.
IF OBJECT_ID('tempDB..#Ward2Specialty') IS NOT NULL
	DROP TABLE #Ward2Specialty

IF OBJECT_ID('tempDB..#DistinctWard2Specialty') IS NOT NULL
	DROP TABLE #DistinctWard2Specialty

IF OBJECT_ID('tempDB..#DistinctWardCode') IS NOT NULL
	DROP TABLE #DistinctWardCode

-- 24Apr08 JKu Replaced
-- CREATE TABLE #Ward2Specialty (
--	WardCode VARCHAR (20) NULL
--,	SpecialtyCode VARCHAR (250) NULL
--)
SELECT * INTO #Ward2Specialty FROM rWard2Specialty WHERE 1=0

DECLARE @CmdText VARCHAR (2500)
SET @CmdText =
'INSERT INTO #Ward2Specialty 
	SELECT [WardCode],
		   [SpecialtyCode]
	FROM ' + @LiveDB + '.icwsys.WReportingWard2Speciality'

EXECUTE (@CmdText)

-- Return if no records found in spreadsheet.
IF (SELECT COUNT(WardCode) FROM #Ward2Specialty) = 0
	BEGIN
		PRINT 'WARD TO SPECIALTY LINKS ARE EMPTY!'
		RETURN
	END

-- Get rid of blanks
DELETE FROM #Ward2Specialty WHERE ISNULL(WardCode, '') = ''

-- Create a table of distinct specialty codes. Only the first instance of other fields will be taken.
SELECT 
	WardCode 
,	MIN(SpecialtyCode) SpecialtyCode
INTO #DistinctWard2Specialty
FROM #Ward2Specialty
GROUP BY WardCode 

TRUNCATE TABLE rWard2Specialty

INSERT INTO rWard2Specialty (
	WardCode, 
	SpecialtyCode
)
(SELECT  
	WardCode, 
	SpecialtyCode 
FROM #DistinctWard2Specialty)

-- Now we append the ward codes that are found in the rTranslog but not in the spreadsheet
SELECT DISTINCT ward WardCode
INTO #DistinctWardCode 
FROM rTranslog 
WHERE ISNULL(Ward, '') <> ''

INSERT INTO rWard2Specialty (
	WardCode
,	SpecialtyCode
)
(SELECT A.WardCode, 'XXXXX' SpecialtyCode
FROM #DistinctWardCode A
LEFT JOIN #DistinctWard2Specialty B ON A.WardCode = B.WardCode
WHERE B.WardCode IS NULL)
