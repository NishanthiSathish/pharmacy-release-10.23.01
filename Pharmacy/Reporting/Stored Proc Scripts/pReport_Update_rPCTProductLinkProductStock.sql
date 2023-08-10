-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rPCTProductLinkProductStock') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPCTProductLinkProductStock
GO

CREATE PROCEDURE pReport_Update_rPCTProductLinkProductStock

AS

DECLARE @TEXT	VARCHAR (MAX)
DECLARE @LiveDB	VARCHAR (MAX)

PRINT 'Running pReport_Update_rPCTProductLinkProductStock'

SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rPCTProductLinkProductStock


SET @TEXT = '
	INSERT INTO rPCTProductLinkProductStock (
		[PCTProductLinkProductStockID],
		[ProductStockID],
		[PCTMasterProductID],
		[Primary]
	)
	
	SELECT 
		[PCTProductLinkProductStockID],
		[ProductStockID],
		[PCTMasterProductID],
		[Primary]
	
	FROM ' + @LiveDB + '.icwsys.PCTProductLinkProductStock'

EXECUTE (@TEXT)

PRINT ''
