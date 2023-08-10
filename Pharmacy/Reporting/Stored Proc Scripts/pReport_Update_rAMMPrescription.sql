-- 25May16 KR 39882 Added AMM to reporting db

IF OBJECT_ID('pReport_Update_rAMMPrescription') IS NOT NULL
	DROP PROCEDURE pReport_Update_rAMMPrescription
GO


CREATE PROCEDURE pReport_Update_rAMMPrescription
AS
Begin
    DECLARE @LiveDB VARCHAR(max)
    DECLARE @sql    varchar(max)

    PRINT 'pReport_Update_rAMMPrescription'
    
    --Get the live database name from the rDatabase table
    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')
    
    TRUNCATE TABLE rAMMPrescription
    
    SET @sql = 'INSERT INTO rAMMPrescription (
	                [RequestID],
	                [Description],
                    EpisodeID,
	                Patient_EntityID,	                      	
	                Creator_EntityID,
	                Creator_Initials,
	                CreatedDate,
	                Duration,
	                UnitID_Duration,
	                UnitID_Duration_Description,
	                StartDate_Prescription,
	                StopDate_Prescription,
	                [Request Cancellation],
	                Request_Cancellation__EntityID,
	                Request_Cancellation__Initials,
	                Request_Cancellation__CreatedDate,
                    AMMForManufacture__EntityID,
	                AMMForManufacture__Initials,
	                AMMForManufacture__CreatedDate,
					AMMManufactureComplete,
					AMMManufactureComplete__EntityID,
	                AMMManufactureComplete__Initials,
	                AMMManufactureComplete__CreatedDate)

                SELECT
					p.[RequestID],	                      	
					CAST(r.[Description] as varchar(256))       as [Description],
					eo.EpisodeID,
					e.EntityID                                  as Patient_EntityID,            
					r.EntityID                                  as Creator_EntityID,
					CAST(per_Creator.Initials as varchar(10))   as Creator_Initials,
					r.CreatedDate,
					p.Duration,
					p.UnitID_Duration,
					CAST(u.[Description] as varchar(50))        as UnitID_Duration_Description,          	
					p.StartDate                                 as StartDate_Prescription,
					p.StopDate                                  as StopDate_Prescription,
					rs.[Request Cancellation],
					rs.Request_Cancellation__EntityID,
					CAST(per_Cancel.Initials as varchar(10))    as Request_Cancellation__Initials,
					rs.Request_Cancellation__CreatedDate,
					rs.AMMForManufacture__EntityID,
					CAST(per_Mnfctr.Initials as varchar(10))    as AMMForManufacture__Initials,
					rs.AMMForManufacture__CreatedDate,
					rs.AMMManufactureComplete,
					rs.AMMManufactureComplete__EntityID,
					CAST(per_MnfctrCplt.Initials as varchar(10))    as AMMForManufactureComplete__Initials,
					rs.AMMManufactureComplete__CreatedDate

				FROM ' + @LiveDB + '.icwsys.prescription   p
				JOIN ' + @LiveDB + '.icwsys.Request        r              ON p.RequestID      		= r.RequestID
				JOIN ' + @LiveDB + '.icwsys.EpisodeOrder   eo             ON p.RequestID      		= eo.RequestID
				JOIN ' + @LiveDB + '.icwsys.RequestStatus  rs             ON p.RequestID      		= rs.RequestID
				JOIN ' + @LiveDB + '.icwsys.Episode        e              ON eo.EpisodeID      		= e.EpisodeID
				LEFT JOIN ' + @LiveDB + '.icwsys.Unit      u              ON p.UnitID_Duration 		= u.UnitID
				LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Creator    ON r.EntityID               = per_Creator.EntityID
				LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Cancel     ON rs.Request_Cancellation__EntityID = per_Cancel.EntityID
				LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Mnfctr     ON rs.AMMForManufacture__EntityID = per_Mnfctr.EntityID
				LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_MnfctrCplt ON rs.AMMManufactureComplete__EntityID = per_MnfctrCplt.EntityID
				WHERE rs.AMMForManufacture = 1'
    EXECUTE (@sql)

    PRINT ''    
END
GO
