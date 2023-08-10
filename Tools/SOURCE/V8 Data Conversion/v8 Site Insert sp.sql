IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8SiteInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8SiteInsert
GO


create procedure pV8SiteInsert
(
		@sessionid int
	,	@sitenumber int
)

as

	begin

		declare @_locationid			int
		declare @_locationtypeid	int
		declare @_description		varchar(128)
		declare @_detail				varchar(1024)

		select @_locationid = LocationID
		from Site
		where SiteNumber = @sitenumber
		
		if @_locationid is null
			begin
				select @_locationtypeid = LocationTypeID
				from LocationType
				where [description] = 'Pharmacy Stockholding'

				set @_description = 'Site' + rtrim(cast(@sitenumber as char(15)))
				set @_detail = 'V9.3 Pharmacy System Site Number ' + rtrim(cast(@sitenumber as char(15)))

				exec pSiteInsert	@sessionid,
										0,
										@_locationtypeid,
										0,
										@_description,
										@_detail,
										0,              -- XN 22Aug13 71687 pSiteInsert has changed
										@sitenumber,
	                           @_locationid OUTPUT				
			end 

	end
GO
