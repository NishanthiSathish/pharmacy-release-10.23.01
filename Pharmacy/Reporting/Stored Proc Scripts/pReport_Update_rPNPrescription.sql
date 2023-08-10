-- 14Feb13 XN 30286 Added PN to reporting db

IF OBJECT_ID('pReport_Update_rPNPrescription') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPNPrescription
GO


CREATE PROCEDURE pReport_Update_rPNPrescription
AS
Begin
    DECLARE @LiveDB VARCHAR(max)
    DECLARE @sql    varchar(max)

    PRINT 'pReport_Update_rPNPrescription'
    
    --Get the live database name from the rDatabase table
    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')
    
    TRUNCATE TABLE rPNPrescription
    
    SET @sql = 'INSERT INTO rPNPrescription (
	                [RequestID],
	                [DosingWeight_kg],
	                [PerKiloRules],
	                [CentralLinePresent],
	                [Supply48Hours],
	                [RegimenName],
	                [Volume_ml],
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
	                      	
                    	[Description],
                    	                      	
	                Creator_EntityID,
	                Creator_Initials,
	                CreatedDate,
	                EpisodeID,
	                Patient_EntityID,
                	
	                Duration,
	                UnitID_Duration,
	                UnitID_Duration_Description,
                	
	                StartDate_Prescription,
	                StopDate_Prescription,
                	
	                [Request Cancellation],
	                Request_Cancellation__EntityID,
	                Request_Cancellation__Initials,
	                Request_Cancellation__CreatedDate)
                
                SELECT
	                pn.[RequestID],
	                pn.[DosingWeight_kg],
	                pn.[PerKiloRules],
	                pn.[CentralLinePresent],
	                pn.[Supply48Hours],
	                CAST(pn.[RegimenName] as varchar(90))       as [RegimenName],
	                pn.[Volume_ml],
	                pn.[Nitrogen_grams],
	                pn.[Glucose_grams],
	                pn.[Fat_grams],
	                pn.[Sodium_mmol],
	                pn.[Potassium_mmol],
	                pn.[Calcium_mmol],
	                pn.[Magnesium_mmol],
	                pn.[Zinc_micromol],
	                pn.[Phosphate_mmol],
	                pn.[Selenium_nanomol],
	                pn.[Copper_micromol],
	                pn.[Iron_micromol],
	                pn.[AqueousVitamins_mL],
	                pn.[LipidVitamins_mL],            	
	                      	
	                CAST(r.[Description] as varchar(256))       as [Description],
	                
	                r.EntityID                                  as Creator_EntityID,
	                CAST(per_Creator.Initials as varchar(10))   as Creator_Initials,
	                r.CreatedDate,
	                eo.EpisodeID,
	                e.EntityID                                  as Patient_EntityID,
                	
	                p.Duration,
	                p.UnitID_Duration,
	                CAST(u.Description as varchar(50))          as UnitID_Duration_Description,
                	
	                p.StartDate                                 as StartDate_Prescription,
	                p.StopDate                                  as StopDate_Prescription,
                	
	                rs.[Request Cancellation],
	                rs.Request_Cancellation__EntityID,
	                CAST(per_Cancel.Initials as varchar(10))    as Request_Cancellation__Initials,
	                rs.Request_Cancellation__CreatedDate
    	        FROM ' + @LiveDB + '.icwsys.PNPrescription pn
    	        JOIN ' + @LiveDB + '.icwsys.Prescription   p              ON pn.RequestID      		= p.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.EpisodeOrder   eo             ON pn.RequestID      		= eo.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.Request        r              ON pn.RequestID      		= r.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.RequestStatus  rs             ON pn.RequestID      		= rs.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.Episode        e              ON eo.EpisodeID      		= e.EpisodeID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Unit      u              ON p.UnitID_Duration 		= u.UnitID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Creator    ON r.EntityID                       = per_Creator.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Cancel     ON rs.Request_Cancellation__EntityID= per_Cancel.EntityID'
    EXECUTE (@sql)

    PRINT ''    
END
GO
