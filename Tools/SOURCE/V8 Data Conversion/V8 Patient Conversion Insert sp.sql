IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8PatientConversionInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8PatientConversionInsert
GO

create procedure pV8PatientConversionInsert
					(
						@SessionID int,
						@EntityID int,
						@FilePosn int,
						@LocationID_Site int,
						@Recno char(10),
						@Caseno char(10)
					)

AS

	BEGIN

		BEGIN TRANSACTION

		INSERT INTO V8PatientConversion
		(EntityID, FilePosn, LocationID_Site, Recno, CaseNo)
		VALUES
		(@EntityID, @FilePosn, @LocationID_Site, @Recno, @Caseno)

		IF (@@ERROR = 0)
			COMMIT TRANSACTION
		ELSE
			ROLLBACK TRANSACTION

	END