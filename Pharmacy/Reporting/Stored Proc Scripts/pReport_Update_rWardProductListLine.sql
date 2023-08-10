-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	2Jul14
-- Ref:				88922
-- Description:		Added new rWardProductListLine table this replaces rSupplier where supplier type is L
-- =======================================================================================================
-- 24Feb15 XN Removed ToFollow and added IsIssueAdHoc, and IsMultiIssueOnIssueDate

IF OBJECT_ID('pReport_Update_rWardProductListLine') IS NOT NULL
	DROP PROCEDURE pReport_Update_rWardProductListLine
GO


CREATE PROCEDURE pReport_Update_rWardProductListLine

AS

DECLARE @TEXT 		VARCHAR (max)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rWardProductListLine'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rWardProductListLine

SET @TEXT = 

	'INSERT INTO rWardProductListLine (
            [WWardProductListLineID],
            [Description],
            [ScreenPosn],
            [NSVcode],	    
            [PackSize],
            [PrintLabel],
            [WWardProductListID],
            [TopupLvl],
            [LastIssue],
            [LastIssueDate],
            [DailyIssue],
            Comment,
			IsIssueAdHoc,
			IsMultiIssueOnIssueDate,
            [SiteID],
			_Deleted
		)
	SELECT 	
            [WWardProductListLineID],
            wpll.[Description] as [Description],
            [ScreenPosn],
            [NSVcode],	    
            [PackSize],
            [PrintLabel],
            wpl.[WWardProductListID] as [WWardProductListID],
            [TopupLvl],
            [LastIssue],
            [LastIssueDate],
            [DailyIssue],
            Comment,
			IsIssueAdHoc,
			IsMultiIssueOnIssueDate,
            wpl.[SiteID] as [SiteID],
			_Deleted
	FROM ' + @LiveDB + '.icwsys.WWardProductListLine wpll
	JOIN ' + @LiveDB + '.icwsys.WWardProductList     wpl  ON wpll.WWardProductListID = wpl.WWardProductListID'

EXECUTE (@TEXT)

PRINT ''
GO
