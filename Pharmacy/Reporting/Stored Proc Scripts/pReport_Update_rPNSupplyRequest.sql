-- 14Feb13 XN 30286 Added PN to reporting db
-- 21Jan16 TH 138337 Added DaysRequested

IF OBJECT_ID('pReport_Update_rPNSupplyRequest') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPNSupplyRequest
GO


CREATE PROCEDURE pReport_Update_rPNSupplyRequest
AS
Begin
    DECLARE @LiveDB VARCHAR(max)
    DECLARE @sql    varchar(max)

    PRINT 'Running pReport_Update_rPNSupplyRequest'

    --Get the live database name from the rDatabase table
    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

    -- Truncate existing data
    TRUNCATE TABLE rPNSupplyRequest
    
    SET @sql = 'INSERT INTO rPNSupplyRequest (
	                [RequestID],
	                [RequestID_Parent],
	                [BatchNumber],
	                [AdminStartDate],
	                [NumberOfLabelsAminoCombined],
	                [NumberOfLabelsLipid],
	                [BaxaCompounder],
	                [BaxaIncludeLipid],
	                [PreperationDate],
	                [ExpiryDaysAqueousCombined],
	                [ExpiryDaysLipid],

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
                	
	                PNPrinted,
	                PNPrinted__EntityID, 
	                PNPrinted__Initials, 
	                PNPrinted__CreatedDate,
                	
	                PNIssued,
	                PNIssued__EntityID, 
	                PNIssued__Initials, 
	                PNIssued__CreatedDate,
                	
	                PNSupplyFlag1,
	                PNSupplyFlag1__EntityID, 
	                PNSupplyFlag1__Initials, 
	                PNSupplyFlag1__CreatedDate,
                	
	                PNSupplyFlag2,
	                PNSupplyFlag2__EntityID, 
	                PNSupplyFlag2__Initials, 
	                PNSupplyFlag2__CreatedDate,
                	
	                PNSupplyFlag3,
	                PNSupplyFlag3__EntityID, 
	                PNSupplyFlag3__Initials, 
	                PNSupplyFlag3__CreatedDate,
	                
	                Complete,

                        DaysRequested)
                SELECT
	                pn.[RequestID],
	                r.[RequestID_Parent],
	                pn.[BatchNumber],
	                pn.[AdminStartDate],
	                pn.[NumberOfLabelsAminoCombined],
	                pn.[NumberOfLabelsLipid],
	                pn.[BaxaCompounder],
	                pn.[BaxaIncludeLipid],
	                pn.[PreperationDate],
	                pn.[ExpiryDaysAqueousCombined],
	                pn.[ExpiryDaysLipid],

 	                CAST(r.Description as varchar(256))      as [Description],
                	
	                r.EntityID                               as Creator_EntityID,
	                CAST(per_Creator.Initials as varchar(10))as Creator_Initials,
	                r.CreatedDate,
	                eo.EpisodeID,
	                e.EntityID                               as Patient_EntityID,
                	
	                rs.[Request Cancellation],
	                rs.Request_Cancellation__EntityID,
	                CAST(per_Cancel.Initials as varchar(10)) as Request_Cancellation__Initials,
	                rs.Request_Cancellation__CreatedDate,
                	
	                rs.PNPrinted,
	                rs.PNPrinted__EntityID, 
	                CAST(per_Printed.Initials as varchar(10))as PNPrinted__Initials, 
	                rs.PNPrinted__CreatedDate,
                	
	                rs.PNIssued,
	                rs.PNIssued__EntityID, 
	                CAST(per_Issued.Initials as varchar(10)) as PNIssued__Initials, 
	                rs.PNIssued__CreatedDate,
                	
	                rs.PNSupplyFlag1,
	                rs.PNSupplyFlag1__EntityID, 
	                CAST(per_Flag1.Initials as varchar(10)) as PNSupplyFlag1__Initials, 
	                rs.PNSupplyFlag1__CreatedDate,
                	
	                rs.PNSupplyFlag2,
	                rs.PNSupplyFlag2__EntityID, 
	                CAST(per_Flag2.Initials as varchar(10)) as PNSupplyFlag2__Initials, 
	                rs.PNSupplyFlag2__CreatedDate,
                	
	                rs.PNSupplyFlag3,
	                rs.PNSupplyFlag3__EntityID, 
			CAST(per_Flag3.Initials as varchar(10)) as PNSupplyFlag3__Initials, 
	                rs.PNSupplyFlag3__CreatedDate,
	                
	                rs.Complete,

			sr.daysrequested as DaysRequested

    	        FROM ' + @LiveDB + '.icwsys.PNSupplyRequest  pn
    	        JOIN ' + @LiveDB + '.icwsys.EpisodeOrder     eo           ON pn.RequestID                        = eo.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.Request          r            ON pn.RequestID                        = r.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.SupplyRequest    sr           ON pn.RequestID                        = sr.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.RequestStatus    rs           ON pn.RequestID                        = rs.RequestID
    	        JOIN ' + @LiveDB + '.icwsys.Episode          e            ON eo.EpisodeID                        = e.EpisodeID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person      per_Creator  ON r.EntityID                          = per_Creator.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person      per_Cancel   ON rs.Request_Cancellation__EntityID   = per_Cancel.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person      per_Printed  ON rs.PNPrinted__EntityID              = per_Printed.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person      per_Issued   ON rs.PNIssued__EntityID               = per_Issued.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person      per_Flag1    ON rs.PNSupplyFlag1__EntityID          = per_Flag1.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person      per_Flag2    ON rs.PNSupplyFlag2__EntityID          = per_Flag2.EntityID
    	        LEFT JOIN ' + @LiveDB + '.icwsys.Person      per_Flag3    ON rs.PNSupplyFlag3__EntityID          = per_Flag3.EntityID'
    EXECUTE (@sql)
    
    PRINT ''
END
GO
