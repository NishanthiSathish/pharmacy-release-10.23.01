-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8LookupContextInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8LookupContextInsert
GO

CREATE PROCEDURE pV8LookupContextInsert
	(
			@sessionid				integer
		,	@context					varchar(255)
		,	@wlookupcontextid		integer			OUTPUT
	)
AS
	begin

		select @wlookupcontextid = WLookupContextID from WLookupContext
		where Context = @Context

		if @wlookupcontextid is NULL		
			exec pWLookupContextInsert	@sessionid,
												@context,
												@wlookupcontextid		OUTPUT

	end 
GO


