IF OBJECT_ID('pReport_Update_rGP') IS NOT NULL
	DROP PROCEDURE pReport_Update_rGP
GO

CREATE PROCEDURE pReport_Update_rGP 
AS

-- CHANGE LOG
-- ==========
-- 01Feb08 JKu Completely re-written the bits that pull data in from spreadsheets.
-- 29Apr09 TH F0052134 replaced sys with icwsys
-- 01Mar10 PJC F0057342/F0079143 PCT is now updated via a join on the RegNumber for the GP rather than the EntityID. 
--			   Also includes a check on the uniqueness of the GP in the csv file.
-- 02Aug13 XN  28042 protect against tempdb having different collation to reporting db (would originaly error on line below A.RegNumber = B.RegNumber)
-- 29Nov16 XN  Removed csv file for hosted 147104

DECLARE @LIVE 	VARCHAR(max)
DECLARE @TEXT	VARCHAR(2050)

PRINT 'Running pReport_Update_rGP'

SET @LIVE 	= (SELECT Database_Name FROM rDatabase WHERE Database_Type = 'LIVE')

TRUNCATE TABLE rGP

SET @TEXT =
	'INSERT INTO rGP (
	
		EntityID ,
		GPName ,
		GPClassificationID ,
		RegNumber ,
		Contract ,
		Obstetric ,
		JobShare ,
		Trainer ,
		BoxNumber ,
		DoorNumber ,
		Building ,
		Street ,
		Town ,
		LocalAuthority ,
		District ,
		PostCode ,
		Province ,
		Country ,
		Notes ,
		GPClassification_Description ,
		GPClassification_Detail 
	)
	
	SELECT 
	
		A.EntityID, 
		E.[Description] GPName,
		A.GPClassificationID, 
		A.RegNumber, 
		A.Contract, 
		A.Obstetric, 
		A.JobShare, 
		A.Trainer,
	
		C.BoxNumber, 
		C.DoorNumber, 
		C.Building, 
		C.Street, 
		C.Town, 
		C.LocalAuthority, 
		C.District, 
		C.PostCode, 
		C.Province, 
		C.Country, 
		C.Notes,
	
		D.[Description] GPClassification_Description,
		D.Detail GPClassification_Detail
		
	FROM ' + @LIVE + '.icwsys.GP A
	
	LEFT JOIN ' + @LIVE + '.icwsys.EntityLinkAddress B ON A.EntityID = B.EntityID
	LEFT JOIN ' + @LIVE + '.icwsys.Address C ON B.AddressID = C.AddressID
	LEFT JOIN ' + @LIVE + '.icwsys.GPClassification D ON A.GPClassificationID = D.GPClassificationID
	LEFT JOIN ' + @LIVE + '.icwsys.Entity E ON A.EntityID = E.EntityID'


EXECUTE (@TEXT)

-- We pull data in from spreadsheet from here.

-- Just in case.
IF OBJECT_ID('tempDB..#GP2PCT') IS NOT NULL
	DROP TABLE #GP2PCT

IF OBJECT_ID('tempDB..#DistinctGP2PCT') IS NOT NULL
	DROP TABLE #DistinctGP2PCT

CREATE TABLE #GP2PCT (
	GPCode VARCHAR (20) NULL
,	PCTCode VARCHAR (20) NULL
,	GPName VARCHAR (250) NULL
-- ,	RegNumber VARCHAR (20)  02Aug13 XN 28042 protect against tempdb having different collation to reporting db (would originaly error on line below A.RegNumber = B.RegNumber)
,	RegNumber VARCHAR (20) COLLATE database_default NULL
)

DECLARE @CmdText VARCHAR (2500)
SET @CmdText =
'INSERT INTO #GP2PCT 
	SELECT GPCode,
		   PCTCode,
		   GPName,
		   RegNumber
	FROM ' + @LIVE + '.icwsys.WReportingGp2Pct'

EXECUTE (@CmdText)

-- Return if no records found in spreadsheet.
IF (SELECT COUNT(GPCode) FROM #GP2PCT) = 0
	BEGIN
		PRINT 'GP-PCT LINKS IS EMPTY!'
		RETURN
	END

/* 01Mar10 PJC F0057342F0079143 Replaced by Block below
-- Get rid of blanks
DELETE FROM #GP2PCT WHERE ISNULL(GPCode, '') = ''

-- Create a table of distinct GP codes. Only the first instance of other fields will be taken.
SELECT 
	CAST(GPCode AS INT) EntityID
,	MIN(PCTCode) PCTCode
,	MIN(GPName) GPName
,	MIN(RegNumber) RegNumber
INTO #DistinctGP2PCT
FROM #GP2PCT
GROUP BY GPCode 

-- Now we insert the PCTCode into the rGP table.
UPDATE rGP 
SET PCTCode = B.PCTCode
FROM rGP A INNER JOIN #DistinctGP2PCT B ON A.EntityID = B.EntityID
*/

-- Get rid of blanks
DELETE FROM #GP2PCT WHERE ISNULL(RegNumber, '') = ''

-- Create a table of distinct GP codes. Only the first instance of other fields will be taken.
SELECT 
	GPCode 
,	PCTCode
,	GPName
,	RegNumber
INTO #DistinctGP2PCT
FROM #GP2PCT

if exists(select count(RegNumber), RegNumber from #GP2PCT group by RegNumber having count(RegNumber) > 1)
begin 
	RAISERROR ( 'WReportingGp2Pct has duplicated GP Reg Numbers, Please go to the Pharmacy SSRS Reporting Settings and review the GP to PCT settings.',15 ,1)
end
else
begin
	-- Now we insert the PCTCode into the rGP table.
	UPDATE rGP 
	SET PCTCode = B.PCTCode
	FROM rGP A INNER JOIN #DistinctGP2PCT B ON A.RegNumber = B.RegNumber
end