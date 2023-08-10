IF OBJECT_ID('pReport_Update_rDivision') IS NOT NULL
	DROP PROCEDURE pReport_Update_rDivision
GO

CREATE PROCEDURE pReport_Update_rDivision 
AS

-- CHANGE LOG
-- ==========
-- 01Feb08 JKu Completely re-written SP. 
-- 29Nov16 XN  Removed csv file for hosted 147104

DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rDivision'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

-- Just in case.
IF OBJECT_ID('tempDB..#Division') IS NOT NULL
	DROP TABLE #Division

IF OBJECT_ID('tempDB..#DistinctDivision') IS NOT NULL
	DROP TABLE #DistinctDivision

CREATE TABLE #Division (
	DivisionCode VARCHAR (20) NULL
,	[Description] VARCHAR (250) NULL
)

DECLARE @CmdText VARCHAR (2500)
SET @CmdText =
'INSERT INTO #Division 
	SELECT DivisionCode,
		   Description
	FROM ' + @LiveDB + '.icwsys.WReportingDivision d'

EXECUTE (@CmdText)

-- Return if no records found in spreadsheet.
IF (SELECT COUNT(DivisionCode) FROM #Division) = 0
	BEGIN
		PRINT 'DIVISION EXPANSION IS EMPTY!'
		RETURN
	END

-- Get rid of blanks
DELETE FROM #Division WHERE ISNULL(DivisionCode, '') = ''

-- Create a table of distinct specialty codes. Only the first instance of other fields will be taken.
SELECT 
	DivisionCode 
,	MIN([Description]) [Description]
INTO #DistinctDivision
FROM #Division
GROUP BY DivisionCode 

TRUNCATE TABLE rDivision

INSERT INTO rDivision (
	DivisionCode, 
	[Description]
)
(SELECT  
	DivisionCode, 
	[Description] 
FROM #DistinctDivision)

