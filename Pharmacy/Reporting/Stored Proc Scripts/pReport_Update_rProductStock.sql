--05Mar08 JKu Added line to deal with 00mmyyyy date format.
--29Apr09 TH F0052134 replaced sys with icwsys
--15Oct09 PJC F0066390 Added Message field from ProductStock table.
--26Nov09 PJC F0068262 Added Stocked field from ProductStock table.
--12Apr10 AJK F0072782 Added new fields
--01Dec10 XN  F0099137 Prevented copying over ProductStock rows that match up to two SiteProductData rows (via DrugID) due to corrupt DB data
--19May15 XN  98073 added new fields
--29Apr16 XN  151864 Added fields LabelFormat, minissue, maxissue, IssueWholePack, LiveStockCtrl, StoresPack, TherapheuticCode
--05May16 XN  151864 Fixed TherapeuticCode spelling mistake after code review 

IF OBJECT_ID('fReport_String_To_Date') IS NOT NULL
	DROP FUNCTION fReport_String_To_Date
GO

CREATE FUNCTION fReport_String_To_Date
	(
		@Date	varchar(8)
	,	@Time	varchar(6)
)
	RETURNS DATETIME
AS
BEGIN
	DECLARE @RetTime varchar (8)
	DECLARE @RetDate varchar (20)
	
	--PROCESS THE TIME
	SET @RetTime = LTRIM(RTRIM(isnull(@Time, ''))) 
	IF (@RetTime = '' or LEN(@RetTime) <> 6) SET @RetTime = '000000'
		
	SET @RetTime = LEFT(@RetTime , 2) + ':' + SUBSTRING(@RetTime ,3,2) + ':' + RIGHT(@RetTime ,2)
	
	--PROCESS THE DATE
	SET @RetDate = LTRIM(RTRIM(isnull(@Date	, ''))) 
	IF @RetDate = '' SET @RetDate = null
	IF LEN(@RetDate) = 7 SET @RetDate = '0' + @RetDate 
	IF LEN(@RetDate) <> 8  SET @RetDate = null
	IF SUBSTRING(@RetDate, 1, 2) = '00' SET @RetDate = NULL --05Mar08 JKu Added to deal with 00mmyyyy dates.
	IF @RetDate is not null SET @RetDate = RIGHT(@RetDate , 4) + '-' + SUBSTRING(@RetDate ,3,2) + '-' + LEFT(@RetDate ,2) + ' ' + @RetTime 
	
	Return cast(@RetDate as DateTime)
	
	

END
GO

SET ANSI_NULLS ON
GO

IF OBJECT_ID('pReport_Update_rProductStock') IS NOT NULL
	DROP PROCEDURE pReport_Update_rProductStock
GO


CREATE PROCEDURE pReport_Update_rProductStock

AS

DECLARE @TEXT 			VARCHAR (8000)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rProductStock'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

-- F0099137 XN 01Dec10 Some databases have multiple SiteProductData rows with same DrugID, and DSSMasterSiteID
-- this is completely invalid, and throws up an error when trying to copy to reporting DB (PK vialoation), so get
-- list of drugIDs that only have a single SitePrdouctData row, and only copy across ProductStock items that 
-- relate to this.
IF OBJECT_ID('tempDB..#TempNonDuplicateDrugIDs') IS NOT NULL
	DROP TABLE #TempNonDuplicateDrugIDs
CREATE TABLE #TempNonDuplicateDrugIDs (DrugID int)

SET @TEXT = 'INSERT INTO #TempNonDuplicateDrugIDs (DrugID) 
                SELECT DrugID FROM ' + @LiveDB + '.icwsys.SiteProductData 
                    WHERE DSSMasterSiteID <> 0 
                    GROUP BY DrugID
                    HAVING COUNT(*) = 1'
EXECUTE (@TEXT)
-- End of F0099137 XN 01Dec10
TRUNCATE TABLE rProductStock

SET @TEXT = 

	'INSERT INTO rProductStock (
		[ProductStockID] ,
		[DrugID] ,
		[LocationID_Site] , 
		[Site] ,
		[AnnualUse] ,
		[ReOrderLevel],
		[ReOrderQuantity] ,
		[StockLevel] ,
		[InUse] ,
		[Formulary] ,
		[OrderCycle] ,
		[SupCode] ,
		[LastOrdered] ,		
		[StockTakeStatus] ,
		[Cost] ,
		[LossesGains] ,
		[Local] ,
		[BatchTracking]  ,
		[LastIssued] ,		
		[LastStockTakeDate] ,	
		[LedgerCode] ,
		[UseThisPeriod] ,
		[DateLastPeriodEnd] ,
		[loccode] ,
		[loccode2] ,	
		[NSVCode],
		[message],
		[Stocked],
		[DDDValue],
		[DDDUnits],
		[UserField1],
		[UserField2],
		[UserField3],
		[PIPCode],
		[MasterPIP],
		[HIProduct],
		[EDILinkCode],
		[PNExclude],					-- XN 19May15 Added missing item
		[EyeLabel],						-- XN 19May15 Added missing item
		[PSOLabel],						-- XN 19May15 Added missing item
		[ExpiryWarnDays],				-- XN 19May15 Added missing item
		[LabelDescriptionInPatient],	-- XN 19May15 98073
		[LabelDescriptionOutPatient],	-- XN 19May15 98073
		[LocalDescription],				-- XN 19May15 98073
		[LabelFormat],
		[minissue],
		[maxissue],
		[IssueWholePack],
		[LiveStockCtrl],
		[StoresPack],
		[TherapeuticCode]
		)

	SELECT 	
		ProductStockID,
		a.DrugID,
		LocationID_Site,
		b.SiteNumber,
		anuse AnnualUse,
		cast(isnull(reorderlvl, 0) as float) ReOrderLevel,
		cast(isnull(reorderqty, 0) as float) ReOrderQuantity,
		stocklvl StockLevel,
		InUse,
		Formulary,
		OrderCycle,
		SupCode,
		dbo.fReport_String_To_Date(a.LastOrdered,'''') ,
		StockTakeStatus,
		cast(ISNULL(Cost, 0) as float) / 100 Cost,
		LossesGains,
		[Local],
		BatchTracking,
		dbo.fReport_String_To_Date(a.LastIssued,'''') ,
		dbo.fReport_String_To_Date(a.LastStockTakeDate,a.LastStockTakeTime) ,
		LedCode LedgerCode,
		UseThisPeriod,
		dbo.fReport_String_To_Date(a.DateLastPeriodEnd,'''') ,
		loccode ,
		loccode2 ,
		siscode NSVCode ,
		message,
		sisstock Stocked,
		a.DDDValue,
		a.DDDUnits,
		a.UserField1,
		a.UserField2,
		a.UserField3,
		a.PIPCode,
		a.MasterPIP,
		a.HIProduct,
		a.EDILinkCode,
		a.[PNExclude],					-- XN 19May15 Added missing item
		a.[EyeLabel],					-- XN 19May15 Added missing item
		a.[PSOLabel],					-- XN 19May15 Added missing item
		a.[ExpiryWarnDays],				-- XN 19May15 Added missing item
		a.[LabelDescriptionInPatient],	-- XN 19May15 98073
		a.[LabelDescriptionOutPatient],	-- XN 19May15 98073
		a.[LocalDescription],			-- XN 19May15 98073
		a.LabelFormat,
		a.minissue,
		a.maxissue,
		a.IssueWholePack,
		a.LiveStockCtrl,
		a.StoresPack,
		a.therapcode as TherapeuticCode
	FROM ' + @LiveDB + '.icwsys.ProductStock a 
		join ' + @LiveDB + '.icwsys.site b on a.locationid_site = b.locationid
		join #TempNonDuplicateDrugIDs c  on a.drugid = c.drugid		            -- F0099137 XN 01Dec10 
		join ' + @LiveDB + '.icwsys.SiteProductData d on a.drugid = d.drugid
	WHERE d.DSSMasterSiteID <> 0'
--PRINT @TEXT
EXECUTE (@TEXT)

-- F0099137 XN 01Dec10 
IF OBJECT_ID('tempDB..#TempSiscodes') IS NOT NULL
	DROP TABLE #TempSiscodes

PRINT ''