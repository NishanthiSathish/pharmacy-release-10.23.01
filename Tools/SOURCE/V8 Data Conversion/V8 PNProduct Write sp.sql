IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8PNProductWrite' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8PNProductWrite
GO

Create Procedure [pV8PNProductWrite]
	(
			@CurrentSessionID			int
		,	@LocationID_Site			int
		,	@PNCode						varchar(8)
		,	@StockLookup				varchar(20)
		,	@InUse						bit
		,	@ForPaed					bit
		,	@ForAdult					bit
		,	@Description				varchar(29) 
		,	@SortIndex					int
		,	@PreMix						int
		,	@AqueousOrLipid				char(1)
		,	@MaxmlTotal					float
		,	@MaxmlPerKg					float
		,	@SharePacks					bit
		,	@BaxaMMIg					varchar(13)
		,	@mOsmperml					float
		,	@gH2Operml					float
		,	@SpGrav						float
		,	@LastModDate				datetime
		,	@LastModUser				varchar(3)  
		,	@LastModTerm				varchar(15) 
		,	@Info						varchar(max) 
        
		,	@ContainerVol_mL			float
		,	@Calories_kcals				float
		,	@Nitrogen_grams				float
		,	@Glucose_grams				float
		,	@Fat_grams					float
		,	@Sodium_mmol				float
		,	@Potassium_mmol				float
		,	@Calcium_mmol				float
		,	@Magnesium_mmol				float
		,	@Zinc_micromol				float
		,	@Phosphate_mmol				float
		,	@PhosphateInorganic_mmol	float
		,	@Chloride_mmol				float
		,	@Acetate_mmol				float
		,	@Selenium_nanomol			float
		,	@Copper_micromol			float
		,	@Iron_micromol				float
		,	@Chromium_micromol			float
		,	@Manganese_micromol			float
		,	@Molybdenum_micromol		float
		,	@Iodine_micromol			float
		,	@Fluoride_micromol			float
		,	@Vitamin_A_mcg				float
		,	@Thiamine_mg				float
		,	@Riboflavine_mg				float
		,	@Pyridoxine_mg				float
		,	@Cyanocobalamin_mcg			float
		,	@Pantothenate_mg			float
		,	@Folate_mg					float
		,	@Nicotinamide_mg			float
		,	@Biotin_mcg					float
		,	@Vitamin_C_mg				float
		,	@Vitamin_D_mcg				float
		,	@Vitamin_E_mg				float
		,	@Vitamin_K_mcg				float
--		,	@Protein_grams				float		9Sep14 XN 9565 removed protein 

		,	@PNProductID				Int Output
	)
	as
      
begin
	declare @PNProductIDlocal int
	
	begin transaction

		Select @PNProductIDlocal = PNProductID 
		from PNProduct 
		where LocationID_Site = @LocationID_Site and PNCode = @PNCode
		
		-- Delete existing row if present then re-insert
		if not @PNProductIDlocal is null
				delete PNproduct where PNProductID = @PNProductIDlocal 

		exec pPNproductInsert	
				@CurrentSessionID 
			,	@LocationID_Site
			,	@PNCode
			,	@InUse
			,	@ForAdult
			,	@ForPaed
			,	@Description 
			,	@SortIndex
			,	@PreMix
			,	@AqueousOrLipid
			,	@MaxmlTotal
			,	@MaxmlPerKg
			,	@SharePacks
			,	@BaxaMMIg 
			,	@mOsmperml
			,	@gH2Operml
			,	@SpGrav
			,	@LastModDate 
			,	@LastModUser 
			,	@LastModTerm 
			,	@Info 
			,	@ContainerVol_mL
			,	@Calories_kcals
			,	@Nitrogen_grams
			,	@Glucose_grams
			,	@Fat_grams
			,	@Sodium_mmol
			,	@Potassium_mmol
			,	@Calcium_mmol
			,	@Magnesium_mmol
			,	@Zinc_micromol
			,	@Phosphate_mmol
			,	@PhosphateInorganic_mmol
			,	@Chloride_mmol
			,	@Acetate_mmol
			,	@Selenium_nanomol
			,	@Copper_micromol
			,	@Iron_micromol
			,	@Chromium_micromol
			,	@Manganese_micromol
			,	@Molybdenum_micromol
			,	@Iodine_micromol
			,	@Fluoride_micromol
			,	@Vitamin_A_mcg
			,	@Thiamine_mg
			,	@Riboflavine_mg
			,	@Pyridoxine_mg
			,	@Cyanocobalamin_mcg
			,	@Pantothenate_mg
			,	@Folate_mg
			,	@Nicotinamide_mg
			,	@Biotin_mcg
			,	@Vitamin_C_mg
			,	@Vitamin_D_mcg
			,	@Vitamin_E_mg
			,	@Vitamin_K_mcg
			--,	@Protein_grams		9Sep14 XN 9565 removed protein 
			,	@StockLookup
			,	@PNProductIDlocal OUTPUT

	If @@ERROR = 0 
		begin
			set @PNProductID=@PNProductIDlocal
			Commit 
		end
	else 
		begin
			Rollback
		end

end


GO


