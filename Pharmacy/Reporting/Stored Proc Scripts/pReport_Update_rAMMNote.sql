-- 25May16 KR 39882 Added AMM to reporting db

IF OBJECT_ID('pReport_Update_rAMMNote') IS NOT NULL
	DROP PROCEDURE pReport_Update_rAMMNote
GO


CREATE PROCEDURE pReport_Update_rAMMNote
AS
Begin
    DECLARE @LiveDB VARCHAR(max)
    DECLARE @sql    varchar(max)

    PRINT 'pReport_Update_rAMMNote'
    
    --Get the live database name from the rDatabase table
    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')
    
    TRUNCATE TABLE rAMMNote
    
	-- Insert the Attached Notes + AMMReportError Notes
    SET @sql = 'INSERT INTO rAMMNote (
					NoteID,
					AMMSupplyRequestID,
					NoteType,
					[Description],
					ReportErrorReason,
					ReportErrorComments,
					Creator_EntityID,
					Creator_Initials,
					CreatedDate)
		
				SELECT
					n.NoteID,
					r.RequestID AS AMMSupplyRequestID,
					t.[Description] AS NoteType,
					n.[Description],
					'''' AS ReportErrorReason,
					'''' AS ReportErrorComments,
					n.EntityID AS Creator_EntityID,
					CAST(p.Initials AS varchar(10)) AS Creator_Initials,
					n.CreatedDate AS CreatedDate
				FROM ' + @LiveDB + '.icwsys.AMMSupplyRequest r
				JOIN ' + @LiveDB + '.icwsys.RequestLinkAttachedNote l on r.RequestID = l.requestID 
				JOIN ' + @LiveDB + '.icwsys.Note n on l.NoteID = n.NoteID
				JOIN ' + @LiveDB + '.icwsys.NoteType t on n.NoteTypeID = t.NoteTypeID 
				LEFT JOIN ' + @LiveDB + '.icwsys.Person p on n.EntityID = p.EntityID

				UNION

				SELECT
					n.NoteID,
					r.RequestID AS AMMSupplyRequestID,
					t.[Description] AS NoteType,
					n.[Description],
					er.[Description] AS ReportErrorReason,
					e.Comments AS ReportErrorComments,
					n.EntityID AS Creator_EntityID,
					CAST(p.Initials AS varchar(10)) AS Creator_Initials,
					n.CreatedDate AS CreatedDate
				FROM ' + @LiveDB + '.icwsys.AMMSupplyRequest r
				JOIN ' + @LiveDB + '.icwsys.NoteLinkRequest l on r.RequestID = l.requestID 
				JOIN ' + @LiveDB + '.icwsys.Note n on l.NoteID = n.NoteID
				JOIN ' + @LiveDB + '.icwsys.NoteType t on n.NoteTypeID = t.NoteTypeID 
				JOIN ' + @LiveDB + '.icwsys.AMMReportError e on n.NoteID = e.NoteID
				LEFT JOIN ' + @LiveDB + '.icwsys.AMMReportErrorReason er on e.AMMReportErrorReasonID = er.AMMReportErrorReasonID
				LEFT JOIN ' + @LiveDB + '.icwsys.Person p on n.EntityID = p.EntityID
				WHERE t.[Description] <> ''AMM State Change'''

    EXECUTE (@sql)

    PRINT ''    
END
GO
