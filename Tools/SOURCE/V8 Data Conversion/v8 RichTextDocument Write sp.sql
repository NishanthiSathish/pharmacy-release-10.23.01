IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8RichTextDocumentWrite' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8RichTextDocumentWrite
GO

Create Procedure [pV8RichTextDocumentWrite]
	(
			@CurrentSessionID   int
		,	@Description        varchar(max)
		,	@Detail             varchar(max)
		,   @Routine            varchar(max)
		,	@RichTextDocumentID int OUTPUT
	)
	as

begin
    DECLARE @MediaTypeID        int
    DECLARE @RoutineID          int
    DECLARE @OrderReportTypeID  int
    
    SELECT TOP 1 @RichTextDocumentID = RichTextDocumentID FROM RichTextDocument WHERE Description = @Description
    
    IF @RichTextDocumentID IS NULL
    BEGIN
        INSERT INTO RichTextDocument ([Description], Detail) VALUES (@Description, @Detail)
        
        SET @RichTextDocumentID = ( SELECT TOP 1 RichTextDocumentID FROM RichTextDocument WHERE Description   = @Description )
        SET @OrderReportTypeID  = ( SELECT TOP 1 OrderReportTypeID  FROM OrderReportType  WHERE [Description] = 'Stand-alone')
        SET @MediaTypeID        = ( SELECT TOP 1 MediaTypeID        FROM MediaType        WHERE [Description] = 'A4' )
        SET @RoutineID          = ( SELECT TOP 1 RoutineID          FROM Routine          WHERE [Description] = @Routine )
        
        INSERT INTO OrderReport (	OrderReportTypeID,
							        MediaTypeID,
							        RequestTypeID,
							        ResponseTypeID,
							        NoteTypeID,
							        TableID,
							        RichTextDocumentID,
							        RoutineID,
							        [Description],
							        OrderTemplateID_Orderset,
							        ModalityID,
							        MarginTop,
							        MarginBottom,
							        MarginLeft,
							        MarginRight	)
        VALUES (	@OrderReportTypeID,
			        @MediaTypeID,
			        0,
			        0,
			        0,
			        0,
			        @RichTextDocumentID,
			        @RoutineID,
			        @Description,
			        0,
			        0,
			        NULL,
			        NULL,
			        NULL,
			        NULL )			        
    END
    ELSE
    BEGIN
        UPDATE RichTextDocument SET detail = @Detail WHERE RichTextDocumentID = @RichTextDocumentID
    END
end
GO