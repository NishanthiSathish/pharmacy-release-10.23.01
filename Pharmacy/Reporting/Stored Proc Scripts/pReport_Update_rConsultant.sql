IF OBJECT_ID('pReport_Update_rConsultant') IS NOT NULL
	DROP PROCEDURE pReport_Update_rConsultant
GO

CREATE PROCEDURE pReport_Update_rConsultant
AS

DECLARE @CMDTEXT	VARCHAR (1000)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rConsultant'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rConsultant

SET @CMDTEXT = '
	INSERT INTO rConsultant (
		Consultant,
		GMCCode,	
		ConsultantName,
		Tel
	)
	
	SELECT 	
		C.Alias Consultant, 
		ISNULL(MIN(A.GMCCode),'''') GMCCode,
		MIN(B.[Description]) ConsultantName, 
		MIN(B.Telephone) Tel
	
	FROM ' + @LiveDB + '.icwsys.Consultant A
	
	LEFT JOIN ' + @LiveDB + '.icwsys.Entity B ON A.EntityID = B.EntityID
	INNER JOIN ' + @LiveDB + '.icwsys.EntityAlias C ON A.EntityID = C.EntityID
	
	GROUP BY C.Alias'

EXECUTE (@CMDTEXT)

PRINT ''
