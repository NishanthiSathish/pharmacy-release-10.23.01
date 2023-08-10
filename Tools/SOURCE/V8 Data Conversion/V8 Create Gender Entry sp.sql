-- =============================================
-- Create procedure with OUTPUT Parameters
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8CreateGenderEntry' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8CreateGenderEntry
GO

CREATE PROCEDURE pV8CreateGenderEntry 
	(
		@SessionID 		int,
		@Description	varchar(20)
	)
AS
	BEGIN

		DECLARE @GenderID int

		SELECT @GenderID = GenderID
		FROM Gender
		WHERE [Description] = @Description
	
		IF @GenderID IS NULL
			EXEC pGenderInsert @SessionID, @Description, @GenderID OUTPUT
	END
GO

