-- =======================================================================================================
-- Author:	Aidan Kent
-- Create date: 09/10/2008
-- Description:	Repopulates the rSiteProductData table
-- =======================================================================================================
--29Apr09 TH F0052134 replaced sys with icwsys
--08Oct09 PJC Added DROP of SP before it is recreated F0065501
--12Apr10 AJK F0072782 Added PASANPCCode
--19May15 XN  98073 added new fields

IF OBJECT_ID('pReport_Update_rSiteProductData') IS NOT NULL
	DROP PROCEDURE pReport_Update_rSiteProductData
GO

CREATE PROCEDURE pReport_Update_rSiteProductData
AS

DECLARE @TEXT 			VARCHAR (8000)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rSiteProductData'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rSiteProductData

SET @TEXT = 

	'INSERT INTO rSiteProductData(
		[barcode],
		[siscode],
		[code],
		[labeldescription],
		[tradename],
		[printformv],
		[storesdescription],
		[convfact],
		[mlsperpack],
		[cyto],
		[warcode],
		[warcode2],
		[inscode],
		[DosesperIssueUnit],
		[DosingUnits],
		[DPSForm],
		[DrugID],
		[LabelInIssueUnits],
		[CanUseSpoon],
		[DSSMasterSiteID],
		[SiteProductDataID],
		[BNF],
		[ProductID],
		[PASANPCCode],
		[DMandDReference]				-- XN 19May15 Added missing item
	)

	SELECT 	
		[barcode],
		[siscode],
		[code],
		[labeldescription],
		[tradename],
		[printformv],
		[storesdescription],
		[convfact],
		[mlsperpack],
		[cyto],
		[warcode],
		[warcode2],
		[inscode],
		[DosesperIssueUnit],
		[DosingUnits],
		[DPSForm],
		[DrugID],
		[LabelInIssueUnits],
		[CanUseSpoon],
		[DSSMasterSiteID],
		[SiteProductDataID],
		[BNF],
		[ProductID],
		[PASANPCCode],
		[DMandDReference]				-- XN 19May15 Added missing item

	FROM ' + @LiveDB + '.icwsys.SiteProductData'
--PRINT @TEXT
EXECUTE (@TEXT)

PRINT ''

GO
