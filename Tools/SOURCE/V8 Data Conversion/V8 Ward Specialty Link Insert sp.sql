IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8WardSpecialtyInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8WardSpecialtyInsert
GO

create procedure pV8WardSpecialtyInsert
	(
			@sessionid					integer
		,	@locationid_site			integer
		,	@ward							varchar(5)
		,	@specialty					varchar(5)
		,  @wwardlinkspecialtyid	integer OUTPUT
	)
AS
	BEGIN

		exec pWWardLinkSpecialtyInsert	@sessionid,
													@locationid_site, 
													@ward,
													@specialty,
													@wwardlinkspecialtyid OUTPUT

	END