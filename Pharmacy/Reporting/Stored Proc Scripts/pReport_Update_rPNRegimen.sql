-- 14Feb13 XN 30286 Added PN to reporting db

IF OBJECT_ID('pReport_Update_rPNRegimen') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPNRegimen
GO


CREATE PROCEDURE pReport_Update_rPNRegimen
AS
Begin
    DECLARE @LiveDB	VARCHAR(max)
    DECLARE @sql    varchar(max)

    PRINT 'Running pReport_Update_rPNRegimen'

    --Get the live database name from the rDatabase table
    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

    TRUNCATE TABLE rPNRegimen
    
    SET @sql = 'INSERT INTO rPNRegimen (
	                [RequestID],
	                [RequestID_Parent],
	                [LocationID_Site],
	                [Volume_mL],
	                [Nitrogen_grams],
	                [Glucose_grams],
	                [Fat_grams],
	                [Sodium_mmol],
	                [Potassium_mmol],
	                [Calcium_mmol],
	                [Magnesium_mmol],
	                [Zinc_micromol],
	                [Phosphate_mmol],
	                [Selenium_nanomol],
	                [Copper_micromol],
	                [Iron_micromol],
	                [AqueousVitamins_mL],
	                [LipidVitamins_mL],
	                [IsCombined],
	                [CentralLineOnly],
	                [InfusionHoursAqueousOrCombined],
	                [InfusionHoursLipid],
	                [SupplyLipidSyringe],
	                [Supply48Hours],
	                [OverageAqueousOrCombined],
	                [OverageLipid],  
	                
	                [LastModDate],
	                [LastModEntityID_User],
	                [LastModEntity_Initials],		
	                [LastModTerminal],
	                [LastModTerminal_Name], 
	                
	                [NumberOfSyringes],
	                [ModificationNumber],                	
	                
	                TotalVolume_mL,
	                TotalCalories_kcals,
	                TotalNitrogen_grams,
	                TotalGlucose_grams,
	                TotalFat_grams,
	                TotalSodium_mmol,
	                TotalPotassium_mmol,
	                TotalCalcium_mmol,
	                TotalMagnesium_mmol,
	                TotalZinc_micromol,
	                TotalPhosphate_mmol,
	                TotalChloride_mmol,
	                TotalAcetate_mmol,
	                TotalSelenium_nanomol,
	                TotalCopper_micromol,
	                TotalIron_micromol,
	                TotalVolume_mLPerkg,
	                TotalCalories_kcalsPerkg,
	                TotalNitrogen_gramsPerkg,
	                TotalGlucose_gramsPerkg,
	                TotalFat_gramsPerkg,
	                TotalSodium_mmolPerkg,
	                TotalPotassium_mmolPerkg,
	                TotalCalcium_mmolPerkg,
	                TotalMagnesium_mmolPerkg,
	                TotalZinc_micromolPerkg,
	                TotalPhosphate_mmolPerkg,
	                TotalChloride_mmolPerkg,
	                TotalAcetate_mmolPerkg,
	                TotalSelenium_nanomolPerkg,
	                TotalCopper_micromolPerkg,
	                TotalIron_micromolPerkg,
    	                
	                [Description],                	
	                
	                Creator_EntityID,
	                Creator_Initials,
	                CreatedDate,
	                EpisodeID,
	                Patient_EntityID,
	                
	                [Request Cancellation],
	                Request_Cancellation__EntityID,
	                Request_Cancellation__Initials,
	                Request_Cancellation__CreatedDate,                	
	                
	                [PNAuthorised],
	                PNAuthorised__EntityID,
	                PNAuthorised__Initials,
	                PNAuthorised__CreatedDate)
                SELECT
	                pnreg.[RequestID],
	                r.[RequestID_Parent],
	                pnreg.[LocationID_Site],
	                pnreg.[Volume_mL],
	                pnreg.[Nitrogen_grams],
	                pnreg.[Glucose_grams],
	                pnreg.[Fat_grams],
	                pnreg.[Sodium_mmol],
	                pnreg.[Potassium_mmol],
	                pnreg.[Calcium_mmol],
	                pnreg.[Magnesium_mmol],
	                pnreg.[Zinc_micromol],
	                pnreg.[Phosphate_mmol],
	                pnreg.[Selenium_nanomol],
	                pnreg.[Copper_micromol],
	                pnreg.[Iron_micromol],
	                pnreg.[AqueousVitamins_mL],
	                pnreg.[LipidVitamins_mL],
	                pnreg.[IsCombined],
	                pnreg.[CentralLineOnly],
	                pnreg.[InfusionHoursAqueousOrCombined],
	                pnreg.[InfusionHoursLipid],
	                pnreg.[SupplyLipidSyringe],
	                pnreg.[Supply48Hours],
	                pnreg.[OverageAqueousOrCombined],
	                pnreg.[OverageLipid],      
	                
	                pnreg.[LastModDate],
	                pnreg.[LastModEntityID_User],
	                CAST(per_LastMod.Initials as varchar(10)) 	as [LastModEntity_Initials],		
	                pnreg.[LastModTerminal],
	                CAST(term.ComputerName as varchar(15)) 		as [LastModTerminal_Name],                	
	                
	                pnreg.[NumberOfSyringes],
	                pnreg.[ModificationNumber],                	
	                
	                pnreg.TotalVolume_mL,
	                pnreg.TotalCalories_kcals,
	                pnreg.TotalNitrogen_grams,
	                pnreg.TotalGlucose_grams,
	                pnreg.TotalFat_grams,
	                pnreg.TotalSodium_mmol,
	                pnreg.TotalPotassium_mmol,
	                pnreg.TotalCalcium_mmol,
	                pnreg.TotalMagnesium_mmol,
	                pnreg.TotalZinc_micromol,
	                pnreg.TotalPhosphate_mmol,
	                pnreg.TotalChloride_mmol,
	                pnreg.TotalAcetate_mmol,
	                pnreg.TotalSelenium_nanomol,
	                pnreg.TotalCopper_micromol,
	                pnreg.TotalIron_micromol,
	                pnreg.TotalVolume_mLPerkg,
	                pnreg.TotalCalories_kcalsPerkg,
	                pnreg.TotalNitrogen_gramsPerkg,
	                pnreg.TotalGlucose_gramsPerkg,
	                pnreg.TotalFat_gramsPerkg,
	                pnreg.TotalSodium_mmolPerkg,
	                pnreg.TotalPotassium_mmolPerkg,
	                pnreg.TotalCalcium_mmolPerkg,
	                pnreg.TotalMagnesium_mmolPerkg,
	                pnreg.TotalZinc_micromolPerkg,
	                pnreg.TotalPhosphate_mmolPerkg,
	                pnreg.TotalChloride_mmolPerkg,
	                pnreg.TotalAcetate_mmolPerkg,
	                pnreg.TotalSelenium_nanomolPerkg,
	                pnreg.TotalCopper_micromolPerkg,
	                pnreg.TotalIron_micromolPerkg,
    	                	                
	                CAST(r.Description as varchar(256)) 		as [Description],                	
	                
	                r.EntityID as Creator_EntityID,
	                CAST(per_Creator.Initials as varchar(10)) 	as Creator_Initials,
	                r.CreatedDate as CreatedDate,
	                eo.EpisodeID,
	                e.EntityID as Patient_EntityID,
	                
	                rs.[Request Cancellation],
	                rs.Request_Cancellation__EntityID,
	                CAST(per_Cancel.Initials as varchar(10)) 	as Request_Cancellation__Initials,
	                rs.Request_Cancellation__CreatedDate,                	
	                
	                rs.[PNAuthorised],
	                rs.PNAuthorised__EntityID,
	                CAST(per_Auth.Initials as varchar(10)) 		as PNAuthorised__Initials,
	                rs.PNAuthorised__CreatedDate                
    	        FROM ' + @LiveDB + '.icwsys.PNRegimen      pnreg
    	        JOIN ' + @LiveDB + '.icwsys.EpisodeOrder   eo             ON pnreg.RequestID                  = eo.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.Request        r              ON pnreg.RequestID                  = r.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.RequestStatus  rs             ON pnreg.RequestID                  = rs.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.Episode        e              ON eo.EpisodeID                     = e.EpisodeID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Creator    ON r.EntityID                       = per_Creator.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Cancel     ON rs.Request_Cancellation__EntityID= per_Cancel.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Auth       ON rs.PNAuthorised__EntityID        = per_Auth.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_LastMod    ON pnreg.LastModEntityID_User       = per_LastMod.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Terminal  term           ON pnreg.[LastModTerminal]          = term.LocationID'
    EXECUTE (@sql)

    PRINT ''
END
GO
