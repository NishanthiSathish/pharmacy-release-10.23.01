-- =============================================
-- Create procedure with OUTPUT Parameters
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8CreateEntityRoleEntry' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8CreateEntityRoleEntry
GO

CREATE PROCEDURE pV8CreateEntityRoleEntry 
	(
		@SessionID 		int,
		@Description	varchar(50),
		@Detail			varchar(1024)
	)
AS
	BEGIN

		DECLARE @EntityRoleID int

		SELECT @EntityRoleID = EntityRoleID
		FROM EntityRole
		WHERE [Description] = @Description
	
		IF @EntityRoleID IS NULL
			EXEC pEntityRoleInsert 	@SessionID, 
										  	@Description, 
											@Detail,
											@EntityRoleID OUTPUT
	END
GO

