IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8ReadptrInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8ReadptrInsert
GO

create procedure pV8ReadptrInsert
	(
			@sessionid			integer
		,	@locationid_site	integer
		,	@category			varchar(255)
		,	@value				integer
		,	@wfilepointerid	integer	OUTPUT
	)
AS
	BEGIN
		
		select @wfilepointerid = wfilepointerid
		from WFilePointer
		where SiteID = @locationid_site
		and Category = @category

		if (@wfilepointerid is null)
			begin
				exec pWFilePointerInsert	@sessionid,
											@locationid_site, 
											@category,
											@value,
											@wfilepointerid OUTPUT
			end
		else
			begin
				exec pWFilePointerWrite		@sessionid,
											@locationid_site, 
											@category,
											@value
			end
	END