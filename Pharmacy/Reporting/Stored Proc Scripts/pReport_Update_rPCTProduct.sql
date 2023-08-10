-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rPCTProduct') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPCTProduct
GO

CREATE PROCEDURE pReport_Update_rPCTProduct

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rPCTProduct'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rPCTProduct


SET @TEXT = '
	INSERT INTO rPCTProduct (
		[BrandCode],
		[BrandName],
		[FormulationName],
		[ChemicalName],
		[PharmaCode],
		[Quantity],
		[Multiple],
		[Specified],
		[Subsidy],
		[Alternate],
		[Price],
		[CBS],
		[OP],
		[SpecialType],
		[SpecialEndorsementType],
		[DrugFileDate],
		[Units],
		[PCTMasterProductID],
		[PCTProductID]
	)
	
	SELECT 
		[BrandCode],
		[BrandName],
		[FormulationName],
		[ChemicalName],
		[PharmaCode],
		[Quantity],
		[Multiple],
		[Specified],
		[Subsidy],
		[Alternate],
		[Price],
		[CBS],
		[OP],
		[SpecialType],
		[SpecialEndorsementType],
		[DrugFileDate],
		[Units],
		[PCTMasterProductID],
		[PCTProductID]
	
	FROM ' + @LiveDB + '.icwsys.PCTProduct'

EXECUTE (@TEXT)

PRINT ''
