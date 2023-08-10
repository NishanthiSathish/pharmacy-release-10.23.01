IF OBJECT_ID('pReport_Update_rDirectorate') IS NOT NULL
	DROP PROCEDURE pReport_Update_rDirectorate
GO

CREATE PROCEDURE pReport_Update_rDirectorate 
AS

-- CHANGE LOG
-- ==========
-- 01Feb08 JKu Completely re-written SP. 
-- 29Nov16 XN  Removed csv file for hosted 147104

DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rDirectorate'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

-- Just in case.
IF OBJECT_ID('tempDB..#Directorate') IS NOT NULL
	DROP TABLE #Directorate

IF OBJECT_ID('tempDB..#DistinctDirectorate') IS NOT NULL
	DROP TABLE #DistinctDirectorate

CREATE TABLE #Directorate (
	DirectorateCode VARCHAR (20) NULL
,	[Description] VARCHAR (250) NULL
)

DECLARE @CmdText VARCHAR (2500)
SET @CmdText =
'INSERT INTO #Directorate 
	SELECT DirectorateCode,
		   Description
		FROM ' + @LiveDB + '.icwsys.WReportingDirectorate d'

EXECUTE (@CmdText)

-- Return if no records found in spreadsheet.
IF (SELECT COUNT(DirectorateCode) FROM #Directorate) = 0
	BEGIN
		PRINT 'DIVISION EXPANSION IS EMPTY!'
		RETURN
	END

-- Get rid of blanks
DELETE FROM #Directorate WHERE ISNULL(DirectorateCode, '') = ''

-- Create a table of distinct specialty codes. Only the first instance of other fields will be taken.
SELECT 
	DirectorateCode 
,	MIN([Description]) [Description]
INTO #DistinctDirectorate
FROM #Directorate
GROUP BY DirectorateCode 

TRUNCATE TABLE rDirectorate

INSERT INTO rDirectorate (
	DirectorateCode, 
	[Description]
)
(SELECT  
	DirectorateCode, 
	[Description] 
FROM #DistinctDirectorate)

