--19Sep12 TH TFS 44280 

exec pDrop 'pV8CreateAliasGroup'

GO

CREATE PROCEDURE [pV8CreateAliasGroup] 
	(
		@SessionID 		int,
		@Description	varchar(50),
		@Detail 			varchar(1024)
	)
AS
	BEGIN

		DECLARE @AliasGroupID	INT

		SELECT @AliasGroupID = AliasGroupID
		FROM AliasGroup
		WHERE [Description] = @Description
	
		IF @AliasGroupID IS NULL
			EXEC pAliasGroupInsert @SessionID, @Description, @Detail,'','',0, @AliasGroupID OUTPUT
	END

GO
