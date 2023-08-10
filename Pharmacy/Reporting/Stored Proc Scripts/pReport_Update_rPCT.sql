IF OBJECT_ID('pReport_Update_rPCT') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPCT
GO

CREATE PROCEDURE pReport_Update_rPCT 
AS

-- CHANGE LOG
-- ==========
-- 01Feb08 JKu Completely re-written SP. 
-- 29Nov16 XN  Removed csv file for hosted 147104

DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rPCT'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

-- Just in case.
IF OBJECT_ID('tempDB..#PCT') IS NOT NULL
	DROP TABLE #PCT

IF OBJECT_ID('tempDB..#DistinctPCT') IS NOT NULL
	DROP TABLE #DistinctPCT

CREATE TABLE #PCT (
	PCTCode VARCHAR (20) NULL
,	[Description] VARCHAR (250) NULL
)

DECLARE @CmdText VARCHAR (2500)
SET @CmdText =
	'INSERT INTO #PCT 
		SELECT PCTCode, 
			   [Description] 
		FROM ' + @LiveDB + '.icwsys.WReportingPct'

EXECUTE (@CmdText)

-- Return if no records found in spreadsheet.
IF (SELECT COUNT(PCTCode) FROM #PCT) = 0
	BEGIN
		PRINT 'PCT IS EMPTY!'
		RETURN
	END

-- Get rid of blanks
DELETE FROM #PCT WHERE ISNULL(PCTCode, '') = ''

-- Create a table of distinct specialty codes. Only the first instance of other fields will be taken.
SELECT 
	PCTCode 
,	MIN([Description]) [Description]
INTO #DistinctPCT
FROM #PCT
GROUP BY PCTCode 

TRUNCATE TABLE rPCT

INSERT INTO rPCT (
	PCTCode, 
	[Description]
)
(SELECT  
	PCTCode, 
	[Description] 
FROM #DistinctPCT)

