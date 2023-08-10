-- 14Feb13 XN 30286 Added PN to reporting db
-- 09Sep14 XN 95647 Removed protein from db

IF OBJECT_ID('pReport_Update_rPNProduct') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPNProduct
GO

CREATE PROCEDURE pReport_Update_rPNProduct
AS
BEGIN
    DECLARE @sql    VARCHAR (max)
    DECLARE @LiveDB	VARCHAR (max)

    PRINT 'Running pReport_Update_rPNProduct'

    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

    TRUNCATE TABLE rPNProduct

    SET @sql =
    'INSERT INTO rPNProduct (
	    [PNProductID],
	    [LocationID_Site],
	    [PNCode],
	    [InUse],
	    [ForAdult],
	    [ForPaed],
	    [Description],
	    [SortIndex],
	    [PreMix],
	    [AqueousOrLipid],
	    [MaxmlTotal],
	    [MaxmlPerKg],
	    [SharePacks],
	    [BaxaMMIg],
	    [mOsmperml],
	    [gH2Operml],
	    [SpGrav],
	    [LastModDate],
	    [LastModUser],
	    [LastModTerm],
	    [Info],
	    [ContainerVol_mL],
	    [Calories_kcals],
	    [Nitrogen_grams],
	    [Glucose_grams],
	    [Fat_grams],
	    [Sodium_mmol],
	    [Potassium_mmol],
	    [Calcium_mmol],
	    [Magnesium_mmol],
	    [Zinc_micromol],
	    [Phosphate_mmol],
	    [PhosphateInorganic_mmol],
	    [Chloride_mmol],
	    [Acetate_mmol],
	    [Selenium_nanomol],
	    [Copper_micromol],
	    [Iron_micromol],
	    [Chromium_micromol],
	    [Manganese_micromol],
	    [Molybdenum_micromol],
	    [Iodine_micromol],
	    [Fluoride_micromol],
	    [Vitamin_A_mcg],
	    [Thiamine_mg],
	    [Riboflavine_mg],
	    [Pyridoxine_mg],
	    [Cyanocobalamin_mcg],
	    [Pantothenate_mg],
	    [Folate_mg],
	    [Nicotinamide_mg],
	    [Biotin_mcg],
	    [Vitamin_C_mg],
	    [Vitamin_D_mcg],
	    [Vitamin_E_mg],
	    [Vitamin_K_mcg],
	    [_RowVersion],
	    [_RowGUID],
	    [_Deleted],
	    [StockLookup])
    
     SELECT  
	    [PNProductID],
	    [LocationID_Site],
	    [PNCode],
	    [InUse],
	    [ForAdult],
	    [ForPaed],
	    [Description],
	    [SortIndex],
	    [PreMix],
	    [AqueousOrLipid],
	    [MaxmlTotal],
	    [MaxmlPerKg],
	    [SharePacks],
	    [BaxaMMIg],
	    [mOsmperml],
	    [gH2Operml],
	    [SpGrav],
	    [LastModDate],
	    CAST([LastModUser] as varchar(3))  [LastModUser],
	    CAST([LastModTerm] as varchar(15)) [LastModTerm],
	    [Info],
	    [ContainerVol_mL],
	    [Calories_kcals],
	    [Nitrogen_grams],
	    [Glucose_grams],
	    [Fat_grams],
	    [Sodium_mmol],
	    [Potassium_mmol],
	    [Calcium_mmol],
	    [Magnesium_mmol],
	    [Zinc_micromol],
	    [Phosphate_mmol],
	    [PhosphateInorganic_mmol],
	    [Chloride_mmol],
	    [Acetate_mmol],
	    [Selenium_nanomol],
	    [Copper_micromol],
	    [Iron_micromol],
	    [Chromium_micromol],
	    [Manganese_micromol],
	    [Molybdenum_micromol],
	    [Iodine_micromol],
	    [Fluoride_micromol],
	    [Vitamin_A_mcg],
	    [Thiamine_mg],
	    [Riboflavine_mg],
	    [Pyridoxine_mg],
	    [Cyanocobalamin_mcg],
	    [Pantothenate_mg],
	    [Folate_mg],
	    [Nicotinamide_mg],
	    [Biotin_mcg],
	    [Vitamin_C_mg],
	    [Vitamin_D_mcg],
	    [Vitamin_E_mg],
	    [Vitamin_K_mcg],
	    [_RowVersion],
	    [_RowGUID],
	    [_Deleted],
	    CAST([StockLookup] as varchar(20)) [StockLookup]
	    FROM ' + @LiveDB + '.icwsys.PNProduct'
    EXECUTE (@sql)	

    PRINT ''
END
GO    
