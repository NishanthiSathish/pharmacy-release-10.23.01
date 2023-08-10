SET ANSI_NULLS ON
GO

-- =======================================================================================================
-- =======================================================================================================
-- This table should not be used for anything that is not in siteproductdata, as it does not include a SiteId field.
-- It is only kept how it is so that it does not break some site reports
-- for other WProduct fields use ProductStock, and WSupplierProfile
-- =======================================================================================================
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rProduct') IS NOT NULL
	DROP PROCEDURE pReport_Update_rProduct
GO


CREATE PROCEDURE pReport_Update_rProduct

AS

-- CHANGE LOG
-- ==========
-- 29Apr09 TH F0052134 replaced sys with icwsys
-- 15Oct09 PJC F0066390 Added Cataloge description (BNF Section/Chapter), ReportGroup
-- 01Dec10 XN  F0102896 UMMC and other sites have a two site with site number 0 which error in reporting db so filter one out

DECLARE @TEXT 			VARCHAR (8000)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rProduct'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rProduct 

SET @TEXT = 

	'INSERT INTO rProduct (
		NSVCode, 
		LabelDescription, 
		TradeName, 
		PrintForm, 
		StoresDescription, 
		ReOrderPacksize, 
		MlsPerPack, 
		cyto, 
		WarCode, 
		WarCode2, 
		InsCode, 
		DosesPerIssueUnit, 
		DosingUnits, 
		DPSForm, 
		[Description], 
		Formulary, 
		LabelFormat, 
		MinUse, 
		MaxUse, 
		LastIssued, 
		IssueWholePack, 
		LiveStockCtrl, 
		SupCode, 
		AltSupCode, 
		LedgerCode, 
		StoresPack, 
		BNFCode, 
		TherapheuticCode, 
		ContractPrice, 
		ContractNumber, 
		OuterPacksize, 
		ReOrderLevel, 
		ReOrderQuantity,
		CatalogueDescription,
		ReportGroup,
		[DMandDReference]				-- XN 19May15 Added missing item
	)

	SELECT 	
		a.SisCode NSVCode,
		MIN(a.labeldescription) LabelDescription,
		MIN(a.tradename) TradeName,
		MIN(a.printformv) PrintForm,
		MIN(a.storesdescription) StoresDescription,
		MIN(a.convfact) ReOrderPacksize,
		MIN(a.mlsperpack) MlsPerPack,
		MIN(a.cyto) cyto,
		MIN(a.warcode) WarCode,
		MIN(a.warcode2) WarCode2,
		MIN(a.inscode) InsCode,
		MIN(a.DosesperIssueUnit) DosesPerIssueUnit,
		MIN(a.DosingUnits) DosingUnits,
		MIN(a.DPSForm) DPSForm,
		MIN(a.description) [Description],
		MIN(a.formulary) Formulary,
		MIN(a.labelformat) LabelFormat,
		MIN(a.minissue) MinUse,
		MIN(a.maxissue) MaxUse,
		MIN(a.lastissued) LastIssued,
		MIN(a.issueWholePack) IssueWholePack,
		MIN(a.livestockctrl) LiveStockCtrl,
		MIN(a.supcode) SupCode,
		MIN(a.altsupcode) AltSupCode,
		MIN(a.ledcode) LedgerCode,
		MIN(a.storespack) StoresPack,
		MIN(a.bnf) BNFCode,
		MIN(a.therapcode) TherapheuticCode,
		MIN(a.contprice) ContractPrice,
		MIN(a.contno) ContractNumber,
		MIN(a.reorderpcksize) OuterPacksize,
		MIN(a.reorderlvl) ReOrderLevel,
		MIN(a.reorderqty) ReOrderQuantity,
		MIN(b.Description) CatalogueDescription,
		MIN(d.Description) ReportGroup,
		MIN(a.DMandDReference) DMandDReference
	FROM ' + @LiveDB + '.icwsys.wProduct a
	LEFT JOIN (
			SELECT x.Description Code, x.Detail Description from  ' + @LiveDB + '.icwsys.ordercatalogue x 
				JOIN ' + @LiveDB + '.icwsys.ordercatalogueroot y on x.ordercataloguerootid = y.ordercataloguerootid
			WHERE y.description = ''BNF''
			  ) b on a.bnf = b.code
	LEFT JOIN ' + @LiveDB + '.icwsys.ProductCustomisation c on c.productid = a.productid
	LEFT JOIN ' + @LiveDB + '.icwsys.ReportGroup d on d.ReportGroupID = c.ReportGroupID
	GROUP BY SisCode'

EXECUTE (@TEXT)

--Do the rSite table in here too.

IF OBJECT_ID('rSite') IS NOT NULL
BEGIN
	TRUNCATE TABLE rSite
	SET @TEXT  = '
		INSERT INTO rSite (
			Site, 	
			Description,
			Detail,
			LocationID)
		SELECT 
			a.SiteNumber Site , 
			b.description, 
			b.detail, 
			a.LocationID 
		FROM 
			' + @LiveDB + '.icwsys.site a 
		JOIN ' + @LiveDB + '.icwsys.location b on a.locationid = b.locationid
		WHERE a.locationid <> 0'	-- F0102896 XN 01Dec10 UMMC and other sites have a two site with site number 0 which error in reporting db so filter one out
	EXECUTE (@TEXT)	
END
	
PRINT ''
