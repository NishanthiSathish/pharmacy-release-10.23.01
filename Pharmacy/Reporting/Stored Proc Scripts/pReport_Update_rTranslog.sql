SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF OBJECT_ID('pReport_Update_rTranslog') IS NOT NULL
	DROP PROCEDURE pReport_Update_rTranslog
GO


CREATE PROCEDURE pReport_Update_rTranslog

AS

Begin
--History
--24Sep07 JKu Added GP code and Specialty code
--17Nov08 CKJ Corrected two quotes to four quotes before EpisodeDescription
--29Apr09 TH F0052134 replaced sys with icwsys
--01Dec10 XN F0099137 Copy over rTranslog data in chunks to prevent out of memory errors when large amount of data
--24Aug11 TH Added prescription reason TFS12007
--14May12 TH Added NHNumber and NHNumberValid TFS26711
--08Jan15 TH Added WWardProductListItemID

DECLARE @TEXT                  VARCHAR (8000)
DECLARE @CONDITION             VARCHAR (100)    -- XN 01Dec10 F0099137
DECLARE @LiveDB                VARCHAR (max)
DECLARE @MaxTransLogID         INT
DECLARE @CountOfRecs           INT
DECLARE @Step                  INT              -- XN 01Dec10 F0099137

PRINT 'Running pReport_Update_rTranslog'

-- XN 01Dec10 F0099137
-- Set number of records to transfer in one go
SET @Step = 100000

--Get the Live database name we to extract our data from.

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

--PREPARE THE PATIENT - GP TEMPORARY LINK TABLE

DECLARE @CMD VARCHAR (2500)

--Clean up

IF OBJECT_ID('tempDB..#PatEntityID2Episode') IS NOT NULL
                DROP TABLE #PatEntityID2Episode

IF OBJECT_ID('tempDB..#Episode2GPEntityID') IS NOT NULL
                DROP TABLE #Episode2GPEntityID

IF OBJECT_ID('PatEntityID2GPEntityID') IS NOT NULL
                DROP TABLE PatEntityID2GPEntityID

 

SET @CMD = ' SELECT 
             EntityID EntityID_Patient, 
             MAX(EpisodeID) EpisodeID 
             INTO #PatEntityID2Episode
             FROM ' + @LiveDB + '.icwsys.Episode 
             WHERE EpisodeID_Parent = 0 AND
             EntityID <> 0      
             GROUP BY EntityID
             SELECT 
             A.EpisodeID, 
             A.EntityID EntityID_GP
             INTO #Episode2GPEntityID
             FROM   ' + @LiveDB + '.icwsys.ResponsibleEpisodeEntity A
             INNER JOIN ' + @LiveDB + '.icwsys.EntityRole B ON A.EntityRoleID = B.EntityRoleID
             WHERE B.[Description] = ''GP'' AND A.Active > 0
          
             SELECT 
             A.EntityID_Patient,
             B.EntityID_GP
             INTO PatEntityID2GPEntityID
             FROM   #PatEntityID2Episode A
             INNER JOIN #Episode2GPEntityID B ON A.EpisodeID = B.EpisodeID'

EXECUTE (@CMD)

--Get the last wTranslogID from rTranslog table

SET @MaxTransLogID = (SELECT MAX(wTransLogID) from dbo.rTranslog)

IF @MaxTransLogID IS NULL       -- First run
                SET @MaxTransLogID = 0

SET @TEXT = ' INSERT INTO rTranslog (
                     WTranslogID, 
                     [Month],
                     Site, 
                     NSVCode, 
                     LogDateTime, 
                     Kind, 
                     LabelType, 
                     CaseNo, 
                     PatId,
                     IssueUnits,
                     ConvFact,
                     DispId, 
                     Terminal, 
                     [IssueDate], 
                     Qty, 
                     Cost, 
                     CostExTax, 
                     TaxCost, 
                     TaxCode, 
                     TaxRate, 
                     Ward, 
                     Consultant, 
                     Specialty, 
                     Prescriber, 
                     DirCode, 
                     Containers,
                     Episode, 
                     EventNumber, 
                     PrescriptionNum, 
                     BatchNum,
                     ExpiryDate, 
                     PPFlag,
                     StockLvl,
                     CustOrdNo,
                     CivasType,
                     CivasAmount,
                     SiteID, 
                     EntityID, 
                     ProductID,
                     BNFCode,
                     EntityID_GP,
                     RequestID_Prescription,
                     PrescriberID,
                     StockValue,
                     PCT,
                     EpisodeDescription,
                     PrescriptionReason,
                     NHNumber,
                     NHNumberValid,
		     WWardProductListItemID)

                SELECT WTranslogID, 
                     SUBSTRING(CAST([date] AS VARCHAR),0,7) [Month],
                     CAST(Site AS INT) Site, 
                     SisCode NSVCode, 
                     LogDateTime, 
                     Kind, 
                     LabelType, 
                     A.CaseNo, 
                     PatId,
                     IssueUnits,
                     ConvFact,
                     DispId, 
                     Terminal, 
                     CONVERT(DATETIME, CAST ([date] AS VARCHAR), 112) [IssueDate], 
                     CAST(Qty AS FLOAT) Qty, 
                     CAST(CONVERT(FLOAT, Cost) AS MONEY) Cost, 
                     CAST(CONVERT(FLOAT, CostExTax) AS MONEY) CostExTax, 
                     CAST(CONVERT(FLOAT, TaxCost) AS MONEY) TaxCost, 
                     TaxCode, 
                     CAST(TaxRate AS FLOAT) TaxRate, 
                     Ward, 
                     Consultant, 
                     CASE WHEN (RTRIM(ISNULL(A.Specialty,'''')) = '''') 
		     	          THEN ISNULL(D.SpecialtyCode, '''')
		     	          ELSE A.Specialty
		                  END Specialty,
                     Prescriber, 
                     DirCode, 
                     CAST(Containers AS FLOAT) Containers,
                     Episode, 
                     EventNumber, 
                     PrescriptionNum, 
                     BatchNum,
                     ExpiryDate, 
                     PPFlag,
                     CAST(StockLvl AS FLOAT) StockLvl,
                     CustOrdNo,
                     CivasType,
                     CAST(CivasAmount AS FLOAT) CivasAmount,
                     SiteID, 
                     A.EntityID, 
                     A.ProductID,
                     B.BNFCode BNFCode,
                     C.EntityID_GP,
                     A.RequestID_Prescription,
                     A.EntityID_Prescriber PrescriberID,
                     StockValue,
                     isNull(E.PCTFlag,0) PCT,
                     isNull(F.[Description],'''') EpisodeDescription,
                     PrescriptionReason,
                     NHNumber,
                     NHNumberValid,
		     WWardProductListItemID


                FROM   ' + @LiveDB + '.icwsys.wTranslog A
                LEFT JOIN rProduct B ON A.SisCode = B.NSVCode
                LEFT JOIN PatEntityID2GPEntityID C ON A.PatID = C.EntityID_Patient
                LEFT JOIN rWard2Specialty D ON A.Ward = D.WardCode
                LEFT JOIN ' + @LiveDB + '.icwsys.PCTRepeat E ON A.RequestID_Prescription= E.RequestID
                LEFT JOIN ' + @LiveDB + '.icwsys.Episode F ON F.EpisodeID = A.Episode '
   
-- XN 01Dec10 F0099137               
-- Transfer the data in chunks (chunk size specified by @Step)                
-- Set @CountOfRecs to 1 to begin with just to kick things off
SET @CountOfRecs = 1
WHILE @CountOfRecs <> 0 
BEGIN
    -- Define condition the gives the size of the chunk
    SET @CONDITION = ' WHERE  (wTranslogID > ' + CAST(@MaxTransLogID AS VARCHAR) + ') AND (wTranslogID <= ' + CAST(@MaxTransLogID + @Step AS VARCHAR) + ')'
    EXECUTE (@TEXT + @CONDITION)
    
    -- Increment counts
    SET @CountOfRecs = @@ROWCOUNT
    SET @MaxTransLogID = @MaxTransLogID + @Step
END

--Clean Up

IF OBJECT_ID('tempDB..#PatEntityID2Episode') IS NOT NULL
                DROP TABLE #PatEntityID2Episode


IF OBJECT_ID('tempDB..#Episode2GPEntityID') IS NOT NULL
                DROP TABLE #Episode2GPEntityID

IF OBJECT_ID('PatEntityID2GPEntityID') IS NOT NULL
                DROP TABLE PatEntityID2GPEntityID
 
PRINT ''

End
GO

SET QUOTED_IDENTIFIER OFF 

GO

SET ANSI_NULLS ON 

GO

 
