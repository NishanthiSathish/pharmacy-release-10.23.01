-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8RxIdxInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8RxIdxInsert
GO

CREATE PROCEDURE pV8RxIdxInsert 
	@SessionID	int, 
	@SiteID		int,
	@V8PatientID	char(10),
	@RxFileName	char(4),
	@RxPosition	int,
	@V8RxIdxID	int OUTPUT
AS
	BEGIN

		SELECT @V8RxIdxID = V8RxIdxID
		FROM V8RxIdx
		WHERE SiteID = @SiteID 
		AND	RxFileName = @RxFileName
		AND	RxPosition = @RxPosition

		IF @V8RxIdxID IS NULL
		BEGIN
			INSERT INTO V8RxIdx
			(SiteID, V8PatientID, RxFileName, RxPosition)
			VALUES
			(@SiteID, @V8PatientID, @RxFileName, @RxPosition)
		
			IF @@ERROR = 0 SET @V8RxIdxID = @@IDENTITY
		END
	END
GO


