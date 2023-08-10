--29Apr09 TH F0052134 replaced sys with icwsys
--21Sep11 AJK 14992 Added some extra code checking to ensure that the only "numeric" values which are let through from the UI which cannot be converted into a float field are chnaged to 0
--29Apr16 XN  123082   Added fields ReOrderLevel, ReOrderQuantity

IF OBJECT_ID('pReport_Update_rSupplierProfile') IS NOT NULL
	DROP PROCEDURE pReport_Update_rSupplierProfile
GO


CREATE PROCEDURE pReport_Update_rSupplierProfile

AS

DECLARE @TEXT 			VARCHAR (8000)
DECLARE @LiveDB		VARCHAR (max)

PRINT 'Running pReport_Update_rSupplierProfile'

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

TRUNCATE TABLE rSupplierProfile

SET @TEXT = 

	'INSERT INTO rSupplierProfile (
		[WSupplierProfileID] , 
		[NSVCode] , 
		[SupCode]  , 
		[ContractNumber] , 
		[OuterPackSize] , 
		[PriceLastPaid] , 
		[ContractPrice] , 
		[LeadTime] , 
		[LastReconcilePrice] , 
		[SuppRefNo] ,
		[LocationID_Site] ,
		[VatRate] ,
		[SupplierTradeName],
		[ReOrderLevel],
		[ReOrderQuantity]
		)
	SELECT 	
		[WSupplierProfileID] , 
		[NSVCode] , 
		[SupCode]  , 
		[ContNo] ContractNumber, 
		[ReorderPckSize] OuterPackSize, 
		CASE WHEN LTRIM(rtrim([SisListPrice])) in(''.'',''-'',''-.'')
			THEN 0
			ELSE CAST(ISNULL([SisListPrice], 0) AS FLOAT)/100
		END PriceLastPaid,
		CASE WHEN LTRIM(rtrim([ContPrice])) in(''.'',''-'',''-.'')
			THEN 0
			ELSE CAST(ISNULL([ContPrice], 0) AS FLOAT)/100
		END ContractPrice, 
		[LeadTime] , 
		CASE WHEN LTRIM(rtrim([LastReconcilePrice])) in(''.'',''-'',''-.'')
			THEN 0
			ELSE CAST(ISNULL([LastReconcilePrice], 0) AS FLOAT)/100
		END LastReconcilePrice, 
		[SuppRefNo] ,
		[LocationID_Site] ,
		[VatRate] ,
		[SupplierTradeName],
		reorderlvl as [ReOrderLevel],
		reorderqty as [ReOrderQuantity]
	FROM ' + @LiveDB + '.icwsys.WSupplierProfile'

EXECUTE (@TEXT)

PRINT ''


