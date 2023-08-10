-- 25May16 KR 39882 Added AMM to reporting db

IF OBJECT_ID('pReport_Update_rAMMSupplyRequest') IS NOT NULL
	DROP PROCEDURE pReport_Update_rAMMSupplyRequest
GO


CREATE PROCEDURE pReport_Update_rAMMSupplyRequest
AS
Begin
    DECLARE @LiveDB VARCHAR(max)
    DECLARE @sql    varchar(max)

    PRINT 'pReport_Update_rAMMSupplyRequest'
    
    --Get the live database name from the rDatabase table
    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')
    
    TRUNCATE TABLE rAMMSupplyRequest
    
    SET @sql = 'INSERT INTO rAMMSupplyRequest (
						RequestID,
						SiteID,
						WFormulaID,
						NSVCode,
						BatchNumber,
						ProductionTrayBarcode,
						ManufactureDate,
						[State],
						[Priority],
						VolumeType,
						VolumeOfInfusion_mL,
						SyringeFillType,
						Dose,
						UnitID_Dose,
						ManufactureShiftID,
						SecondCheckType,
						CompoundingDate,
						EntityID_LastStateUpdate,
						DateTime_LastStateUpdate,
						RequestID_WLabel,
						IssueState,
						EpisodeTypeID,
						PrescriptionId,
						EpisodeId,
						Patient_EntityID,
						Creator_EntityID,
						Creator_Initials,
						CreatedDate,
						[Request Cancellation],
						Request_Cancellation__EntityID,
						Request_Cancellation__Initials,
						Request_Cancellation__CreatedDate,
						Complete,
						QuantityRequested,
						UnitID_Quantity,
						Stage_Schedule_EntityID,
						Stage_Schedule_CreatedDate,
						Stage_Schedule_Initials,
						Stage_ProductionTray_EntityID,
						Stage_ProductionTray_CreatedDate,
						Stage_ProductionTray_Initials,
						Stage_Assembly_EntityID,
						Stage_Assembly_CreatedDate,
						Stage_Assembly_Initials,
						Stage_Check_EntityID,
						Stage_Check_CreatedDate,
						Stage_Check_Initials,
						Stage_Compound_EntityID,
						Stage_Compound_CreatedDate,
						Stage_Compound_Initials,
						Stage_Label_EntityID,
						Stage_Label_CreatedDate,
						Stage_Label_Initials,
						Stage_Final_EntityID,
						Stage_Final_CreatedDate,
						Stage_Final_Initials,
						Stage_BondStore_EntityID,
						Stage_BondStore_CreatedDate,
						Stage_BondStore_Initials,
						Stage_Release_EntityID,
						Stage_Release_CreatedDate,
						Stage_Release_Initials,
						Stage_Complete_EntityID,
						Stage_Complete_CreatedDate,
						Stage_Complete_Initials)
	
				SELECT	
				sr.RequestID,
				sr.SiteID,
				sr.WFormulaID,
				sr.NSVCode,
				sr.BatchNumber,
				sr.ProductionTrayBarcode,
				sr.ManufactureDate,
				sr.[State],
				sr.[Priority],
				sr.VolumeType,
				sr.VolumeOfInfusion_mL,
				sr.SyringeFillType,
				sr.Dose,
				sr.UnitID_Dose,
				sr.ManufactureShiftID,
				sr.SecondCheckType,
				sr.CompoundingDate,
				sr.EntityID_LastStateUpdate,
				sr.DateTime_LastStateUpdate,
				sr.RequestID_WLabel,
				sr.IssueState,
				sr.EpisodeTypeID,
				sr.PrescriptionId,
				eo.EpisodeId,
				e.EntityID									AS Patient_EntityID,
				r.EntityID									AS Creator_EntityID,
				CAST(per_Creator.Initials as varchar(10))   AS Creator_Initials,
				r.CreatedDate,
				rs.[Request Cancellation],
				rs.Request_Cancellation__EntityID,
				CAST(per_Cancel.Initials as varchar(10))	AS Request_Cancellation_Initials,
				rs.Request_Cancellation__CreatedDate,
				rs.Complete,
				s.QuantityRequested,
				s.UnitID_Quantity,

				(SELECT TOP 1 n.EntityID 
				 FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				 JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				 JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				 WHERE asn.ToState = 0 and r.RequestID = sr.RequestID
				 ORDER BY n.CreatedDate DESC)				AS Stage_Schedule_EntityID,

				(SELECT top 1 n.CreatedDate 
				 FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				 JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				 JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				 WHERE asn.ToState = 0 and r.RequestID = sr.RequestID
				 ORDER BY n.CreatedDate DESC)				AS Stage_Schedule_CreatedDate,

				(SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				 FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				 JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				 JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				 LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				 WHERE asn.ToState = 0 and r.RequestID = sr.RequestID
				 ORDER BY n.CreatedDate DESC)				AS Stage_Schedule_Initials,
		   
				(SELECT TOP 1 n.EntityID 
				 FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				 JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				 JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				 WHERE asn.ToState = 1 and r.RequestID = sr.RequestID
				 ORDER BY n.CreatedDate DESC)				AS Stage_ProductionTray_EntityID,

				(SELECT top 1 n.CreatedDate 
				 FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				 JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				 JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				 WHERE asn.ToState = 1 and r.RequestID = sr.RequestID
				 ORDER BY n.CreatedDate DESC)				AS Stage_ProductionTray_CreatedDate,

				(SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				 FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				 JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				 JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				 LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				 WHERE asn.ToState = 1 and r.RequestID = sr.RequestID
				 ORDER BY n.CreatedDate DESC)				AS Stage_ProductionTray_Initials,
		 
				 (SELECT TOP 1 n.EntityID 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  WHERE asn.ToState = 2 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Assembly_EntityID,

				 (SELECT top 1 n.CreatedDate 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				  WHERE asn.ToState = 2 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Assembly_CreatedDate,

				 (SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				  WHERE asn.ToState = 2 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Assembly_Initials,
		
				 (SELECT TOP 1 n.EntityID 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  WHERE asn.ToState = 3 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Check_EntityID,

				 (SELECT top 1 n.CreatedDate 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				  WHERE asn.ToState = 3 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Check_CreatedDate,

				 (SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				  WHERE asn.ToState = 3 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Check_Initials,

				 (SELECT TOP 1 n.EntityID 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  WHERE asn.ToState = 4 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Compound_EntityID,

				 (SELECT top 1 n.CreatedDate 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				  WHERE asn.ToState = 4 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Compound_CreatedDate,

				 (SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				  WHERE asn.ToState = 4 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Compound_Initials,

				 (SELECT TOP 1 n.EntityID 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  WHERE asn.ToState = 5 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Label_EntityID,

				 (SELECT top 1 n.CreatedDate 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				  WHERE asn.ToState = 5 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Label_CreatedDate,

				 (SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				  WHERE asn.ToState = 5 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Label_Initials,

				 (SELECT TOP 1 n.EntityID 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  WHERE asn.ToState = 6 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Final_EntityID,

				 (SELECT top 1 n.CreatedDate 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				  WHERE asn.ToState = 6 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Final_CreatedDate,

				 (SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				  WHERE asn.ToState = 6 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Final_Initials,
		
						 (SELECT TOP 1 n.EntityID 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  WHERE asn.ToState = 7 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_BondStore_EntityID,

				 (SELECT top 1 n.CreatedDate 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				  WHERE asn.ToState = 7 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_BondStore_CreatedDate,

				 (SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				  WHERE asn.ToState = 7 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_BondStore_Initials,
		
				 (SELECT TOP 1 n.EntityID 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  WHERE asn.ToState = 8 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Release_EntityID,

				 (SELECT top 1 n.CreatedDate 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				  WHERE asn.ToState = 8 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Release_CreatedDate,

				 (SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				  WHERE asn.ToState = 8 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Release_Initials,

				 (SELECT TOP 1 n.EntityID 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn 
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  WHERE asn.ToState = 9 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Complete_EntityID,

				 (SELECT top 1 n.CreatedDate 
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n ON asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r ON asn.NoteID = r.noteID 
				  WHERE asn.ToState = 9 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Complete_CreatedDate,

				 (SELECT  TOP 1 CAST(p.Initials AS varchar(10)) AS Initials
				  FROM ' + @LiveDB + '.icwsys.AMMStateChangeNote asn
				  JOIN ' + @LiveDB + '.icwsys.note n on asn.NoteID = n.NoteID
				  JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest r on asn.NoteID = r.noteID 
				  LEFT JOIN ' + @LiveDB + '.icwsys.Person p ON n.EntityID = p.EntityID
				  WHERE asn.ToState = 9 and r.RequestID = sr.RequestID
				  ORDER BY n.CreatedDate DESC)				AS Stage_Complete_Initials
		
		FROM
			' + @LiveDB + '.icwsys.AMMSupplyRequest sr
			JOIN ' + @LiveDB + '.icwsys.SupplyRequest s				ON sr.RequestID = s.RequestID
			JOIN ' + @LiveDB + '.icwsys.Request r						ON sr.RequestID = r.RequestID
			JOIN ' + @LiveDB + '.icwsys.RequestStatus rs				ON r.RequestID = rs.RequestID
			JOIN ' + @LiveDB + '.icwsys.EpisodeOrder eo				ON sr.RequestID = eo.RequestID
			JOIN ' + @LiveDB + '.icwsys.Episode e						ON eo.EpisodeID = e.EpisodeID
			LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Creator    ON r.EntityID = per_Creator.EntityID
			LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Cancel     ON rs.Request_Cancellation__EntityID = per_Cancel.EntityID'

    EXECUTE (@sql)

    PRINT ''    
END
GO
