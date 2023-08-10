--06Feb14 XN Added pConvertedPatientNotesInsert as missing from the blank db (TFS 84033)

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pConvertedPatientNotesInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pConvertedPatientNotesInsert
GO

Create procedure [pConvertedPatientNotesInsert]
      (
                  @CurrentSessionID int
            ,     @NoteTypeID int
            ,     @TableID int
            ,     @EntityID int
            ,     @NoteID_Thread int
            ,     @Description varchar(128)
            ,     @CreatedDate datetime
            ,     @EpisodeID int
            ,     @ConvertedNotes text
            ,     @Truncated bit
            ,     @OrderCatalogueID int
            ,     @NoteID int OUTPUT
      )
      as

begin

      Begin transaction

      exec [pEpisodeNoteInsert] @CurrentSessionID, @NoteTypeID, @TableID, @EntityID, @NoteID_Thread, @Description, @CreatedDate, @EpisodeID, @NoteID OUTPUT

      Insert into [ConvertedPatientNotes] ( [NoteID], [ConvertedNotes], [Truncated], [OrderCatalogueID] ) 
      values ( @NoteID, @ConvertedNotes, @Truncated, @OrderCatalogueID )


      If @@ERROR = 0 Commit else Rollback

end
GO
