IF OBJECT_ID('pReport_Update_rPatients') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPatients
GO

CREATE PROCEDURE pReport_Update_rPatients

AS

--Change log
--27Jun08 JKu NHS Number is now derived from the Entity Alias table with Alias Group Description = 'NHSNumber'
--27Jun08 JKu Case Number added to the rPatient table.
--23Jul08 JKu When creating temporary table for NHSNumber and CaseNumber, the EntityAlias.Default is now set to 1.
--29Apr09 TH F0052134 replaced sys with icwsys
--08Oct09 PJC Now uses PrimaryPatientIdentifier to select NHS number, NHS number kept for backward compatibility. Added new HeathcareNumber after dicussion with TH for future catalog (F0064619)
--15Oct09 PJC F0066390 Added Address information, look up on the rReportingConficuration table for required addresstype.
--19Oct09 TH  Use correct livedb variable (F0066660)
--21Sep11 AJK 14976 Added new table to ensure a unique home address is used
--29Jul15 XN  103086 Added Fixed issue PK violation of patients share addresses


DECLARE @TEXT 				VARCHAR (2500)
DECLARE @LiveDB			VARCHAR (max)
DECLARE @NHSNum_Cmd		VARCHAR (1000)
DECLARE @CaseNum_Cmd		VARCHAR (1000)
DECLARE @AddressType		Varchar(512)
DECLARE @DistinctAdd_Cmd	varchar(max)

PRINT 'Running pReport_Update_rPatients'

TRUNCATE TABLE rPatients

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')
SELECT @AddressType = [Value] FROM rReportingConfiguration where [key] = 'AddressType'

--Create global temporary table for NHS Numbers
--Just in case
IF OBJECT_ID('tempDB..##NHSNumber') IS NOT NULL
	DROP TABLE ##NHSNumber

SET @NHSNum_Cmd = '
SELECT A.EntityID, A.Alias, A.IsValid, A.Alias "HealthCareNumber", A.IsValid "HealthCareNumberValid"
INTO ##NHSNumber 
FROM ' + @LiveDB + '.icwsys.EntityAlias A
INNER JOIN ' + @LiveDB + '.icwsys.AliasGroup B ON A.AliasGroupID = B.AliasGroupID
INNER JOIN ' + @LiveDB + '.icwsys.[Setting] C ON C.[Value] = B.[Description] 
WHERE 
	--B.[Description] = ''NHSNumber'' AND 
	LEN(ISNULL(A.Alias, '''')) > 0 AND 
	A.[Default] = 1 AND
	C.[system] = ''General'' AND
	C.[Section] = ''PatientEditor'' AND
	C.[Key]= ''PrimaryPatientIdentifier'' AND
    C.RoleID = 0'

EXECUTE (@NHSNum_Cmd)

--Create global temporary table for Case Numbers
IF OBJECT_ID('tempDB..##CaseNumber') IS NOT NULL
	DROP TABLE ##CaseNumber

SET @CaseNum_Cmd = '
SELECT A.EntityID, A.Alias
INTO ##CaseNumber 
FROM ' + @LiveDB + '.icwsys.EntityAlias A
INNER JOIN ' + @LiveDB + '.icwsys.AliasGroup B ON A.AliasGroupID = B.AliasGroupID
WHERE B.[Description] = ''CaseNumber'' AND LEN(ISNULL(A.Alias, '''')) > 0 AND A.[Default] = ''1'''

EXECUTE (@CaseNum_Cmd)

SET @DistinctAdd_Cmd = '
SELECT DISTINCT(ela.EntityID), max(ela.AddressID) as AddressID
INTO ##DistinctAdd
FROM ' + @LiveDB + '.icwsys.entitylinkaddress ela
JOIN ' + @LiveDB + '.icwsys.address a on a.addressid = ela.addressid
JOIN ' + @LiveDB + '.icwsys.addresstype at on ela.addresstypeid = at.addresstypeid
where at.description  = ''' + @AddressType + '''
GROUP BY ela.EntityID'

EXECUTE (@DistinctAdd_Cmd)

SET @TEXT = '
INSERT INTO rPatients (

	PatID, 
	Title, 
	Initials, 
	Forename, 
	Surname, 
	DOB, 
	CaseNumber,
	NHSNumber, 
	NHSNumberValid, 
	Sex,
	HealthCareNumber, 
	HealthCareNumberValid,
	[BoxNumber],
	[DoorNumber],
	[Building],
	[Street],
	[Town],
	[LocalAuthority],
	[District],
	[PostCode],
	[Province],
	[Country])

SELECT 

	CONVERT(VARCHAR,B.EntityID) PatID, 
	B.Title, 
	B.Initials, 
	B.Forename, 
	B.Surname,
	A.DOB, 
	E.Alias CaseNumber,
	D.Alias NHSNumber, 
	D.IsValid NHSNumberValid,
	C.[Description] Sex,
	D.HealthCareNumber, 
	D.HealthCareNumberValid,
	G.[BoxNumber],
	G.[DoorNumber],
	G.[Building],
	G.[Street],
	G.[Town],
	G.[LocalAuthority],
	G.[District],
	G.[PostCode],
	G.[Province],
	G.[Country]

FROM
	' + @LiveDB + '.icwsys.Patient A

INNER JOIN ' + @LiveDB + '.icwsys.Person B ON A.EntityID = B.EntityID
INNER JOIN ' + @LiveDB + '.icwsys.Gender C ON A.GenderID = C.GenderID 
LEFT JOIN ##NHSNumber D ON A.EntityID = D.EntityID
LEFT JOIN ##CaseNumber E ON A.EntityID = E.EntityID
LEFT JOIN ##DistinctAdd da ON da.entityID = A.entityID
LEFT JOIN ' + @LiveDB + '.icwsys.address G on da.addressid = G.addressid'

EXECUTE (@TEXT)

--Clean Up
IF OBJECT_ID('tempDB..##NHSNumber') IS NOT NULL
	DROP TABLE ##NHSNumber

IF OBJECT_ID('tempDB..##CaseNumber') IS NOT NULL
	DROP TABLE ##CaseNumber

IF OBJECT_ID('tempDB..##DistinctAdd') IS NOT NULL
	DROP TABLE ##DistinctAdd

PRINT 'rPatient successfully updated.'

